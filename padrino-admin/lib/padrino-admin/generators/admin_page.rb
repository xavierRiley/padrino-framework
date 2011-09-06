module Padrino
  module Generators

    class AdminPage < Thor::Group
      attr_accessor :default_orm

      # Add this generator to our padrino-gen
      Padrino::Generators.add_generator(:admin_page, self)

      # Define the source template root
      def self.source_root; File.expand_path(File.dirname(__FILE__)); end
      def self.banner; "padrino-gen admin_page [model]"; end

      # Include related modules
      include Thor::Actions
      include Padrino::Generators::Actions
      include Padrino::Generators::Admin::Actions

      desc "Description:\n\n\tpadrino-gen admin_page model(s)"
      argument :models, :desc => "The name(s) of your model(s)", :type => :array
      class_option :skip_migration, :aliases => "-s", :default => false, :type => :boolean
      class_option :root, :desc => "The root destination", :aliases => '-r', :type => :string
      class_option :destroy, :aliases => '-d', :default => false, :type => :boolean

      # Show help if no argv given
      require_arguments!

      # Create controller for admin
      def create_controller
        self.destination_root = options[:root]
        if in_app_root?
          models.each do |model|
            @orm = default_orm || Padrino::Admin::Generators::Orm.new(model, adapter)
            
            self.behavior = :revoke if options[:destroy]
            empty_directory destination_root("/admin/views/#{@orm.name_plural}")

            template "templates/page/controller.rb.tt",       destination_root("/admin/controllers/#{@orm.name_plural}.rb")
            #Ask about validations for everything except accounts
            if @orm.name_plural != 'accounts' and ask("Do you want to add validations now for #{@orm.name_plural} (y|n)", :no, :red) == 'y'
              @orm.column_fields.each do |model_field| 
                if ask("Is #{model_field[:name].to_s} required? (y|n)", :no, :red) == 'y'
                  model_field[:required] = true
                end
              end
              template "templates/#{ext}/page/_form.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/_form.#{ext}")
            else
              template "templates/#{ext}/page/_form.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/_form.#{ext}")
            end
            template "templates/#{ext}/page/edit.#{ext}.tt",  destination_root("/admin/views/#{@orm.name_plural}/edit.#{ext}")
            template "templates/#{ext}/page/new.#{ext}.tt",   destination_root("/admin/views/#{@orm.name_plural}/new.#{ext}")

            ## Carrierwave support
            # based on naming convention of '_file' add in carrierwave support
            @orm.column_fields.each do |model_field| 
              if model_field[:name].to_s.index('_file') or model_field[:name].to_s.index('_img')
                empty_directory("public/images/uploads")
                empty_directory("public/uploads")
                prepend_file destination_root("models/#{@orm.name_singular}.rb"), "require 'carrierwave/orm/#{fetch_component_choice(:orm)}'\n"
                inject_into_file destination_root("models/#{@orm.name_singular}.rb"),"   mount_uploader :#{model_field[:name]}, Uploader\n", :before => 'end'
              end
            end

            #Leave the index page till and remove columns based on questions
            #Ask about which fields to display for everything except accounts
            if @orm.name_plural != 'accounts' and ask("Do you want to specify which columns to display for the #{@orm.name_plural} index page? (y|n)", :display_all, :red) == 'y'
              @ignoreFields = []
              @orm.columns.each do |model_field|
                if ask("Display #{model_field.name.to_s}? (y|n)", :no, :red) != 'y'
                  @ignoreFields << model_field.name
                end
              end
              template "templates/#{ext}/page/index.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/index.#{ext}")
            else
              template "templates/#{ext}/page/index.#{ext}.tt", destination_root("/admin/views/#{@orm.name_plural}/index.#{ext}")
            end

            options[:destroy] ? remove_project_module(@orm.name_plural) : add_project_module(@orm.name_plural)
          end
        else
          say "You are not at the root of a Padrino application! (config/boot.rb not found)"
        end
      end
    end # AdminPage
  end # Generators
end # Padrino
