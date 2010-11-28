require 'tilt'
require 'pathname'

module Padrino
  ## 
  # This namespace keeps various rendering options and helpers. 
  #
  module Rendering
    ##
    # Raised when given template doesn't exist.
    #
    class TemplateNotFound < RuntimeError; end
  
    ##
    # This is an array of file patterns to ignore. If your editor add a suffix 
    # during editing to your files please add it like:
    #
    #   Padrino::Rendering::EXCLUDE_PATTERNS << /~$/
    #
    EXCLUDE_PATTERNS = [
      /~$/ # This is for Gedit
    ]
    
    ##
    # Default rendering options used in the #render-method
    #
    DEFAULT_OPTIONS = { 
      :strict_format    => false, 
      :raise_exceptions => true,
      :root_layouts     => false,
    }
    
    class << self
      def included(app) # :nodoc:
        DEFAULT_OPTIONS.each {|k,v| app.set(k, v) } if app.respond_to?(:set) 
        app.send :extend, ClassMethods
        app.send :include, InstanceMethods
      end
      alias :registered :included
    end # << self
    
    module Helpers
      ##
      # Returns all view files from given directory.
      #
      def self.glob_views(path)
        [path, Dir.glob[File.join(path, '**/*.{#{Tilt.mappings.keys.join(",")}}')].map {|file| 
          file.split(path).last unless file.search(Rendering::EXCLUDE_PATTERNS)
        }.compact]
      end
    end
    
    module ClassMethods
      ##
      # Use layout like rails does or if a block given then like sinatra.
      # If used without a block, sets the current layout for the route.
      #
      # By default, searches in your <tt>app/views/layouts/application.*</tt>
      #
      # If you define +layout+ <tt>:custom<tt> then searches for your layouts in
      # <tt>app/views/layouts/custom.*</tt>
      #
      def layout(name=:layout, &block)
        return super(name, &block) if block_given?
        @layout = name
      end
      
      ##
      # Keep cached options for already resolved views. 
      #
      def resolved_views
        @resolved_views ||= {}
      end
      
    end # ClassMethods
    
    module InstanceMethods
      ##
      # Enhancing Sinatra render functionality for using similar to Rails.
      #
      # ==== Examples
      #
      #   # simple usage
      #   render 'path/to/my/template'   # (without symbols)
      #   render 'path/to/my/template'   # (with engine lookup)
      #   render 'path/to/template.haml' # (with explicit engine lookup)
      #
      #   # reneder with/without layouts
      #   render 'path/to/template', :layout => false
      #   render 'path/to/template', :layout => false
      #   render 'path/to/template', :layout => "application"
      #   render 'path/to/template', :layout => false, :engine => 'haml'
      #
      #   # render JSON
      #   render { :a => 1, :b => 2, :c => 3 } # => return a json string
      #
      def render(engine, data=nil, options={}, locals={}, &block)
        # If engine is a hash then render data converted to json
        return engine.to_json if engine.is_a?(Hash)

        # Data can actually be a hash of options in certain cases
        options.merge!(data) && data = nil if data.is_a?(Hash)

        # If an engine is a string then this is a likely a path to be resolved
        data, engine = template_for(engine, options) if data.nil?

        # Sinatra 1.0 requires an outvar for erb and erubis templates
        options[:outvar] ||= '@_out_buf' if [:erb, :erubis] & [engine]

        # Resolve layouts similar to in Rails
        options[:layout] = settings.layout if options[:layout].nil?
        options[:layout] = resolve_layout(options[:layout]) unless options[:layout] == false
        
        # Pass arguments to Sinatra render method
        super(engine, data, options.dup, locals, &block)
      end
      
      ##
      # Returns the template path to given layout.
      #
      # If <tt>:root_layouts</tt> option is enabled then it will search 
      # for given layout directly in views directory, otherwise it will be 
      # looking <tt>{views-path}/layouts</tt>. 
      #
      def resolve_layout(path)
        path = "application" if path.nil?
        path = File.join("layouts", path) unless settings.root_layouts
        resolved = resolve_template(path, :strict_format => true, :raise_exceptions => false)
        resolved ? (resolved.first or false) : false
      end
      private :resolve_layout
      
      ##
      # Returns the template path and engine that match content_type (if present), 
      # locale, etc...
      #
      # ==== Options
      #
      # <tt>:strict_format</tt>:: The resolved template must match the +content_type+ 
      #   of the request (defaults to false).
      # <tt>:raise_exceptions</tt>:: Raises a +TemplateNotFound+ exception if the 
      #   template cannot be located.
      #
      # ==== Examples
      #
      #   get "/foo", :provides => [:html, :js] do
      #     render 'path/to/foo'
      #   end
      # 
      # If you request <tt>/foo.js</tt> with <tt>I18n.locale == :ru</tt> then produces:
      #
      #   [:"/path/to/foo.ru.js.erb", :erb]
      #
      # If you request <tt>/foo</tt> with <tt>I18n.locale == :de</tt> then produces:
      #
      #   [:"/path/to/foo.de.haml", :haml]
      #
      def resolve_template(path, options={})
        # Fix given template path
        path.sub!(/^\/+/, '')
        
        # Resolve explicit template format
        format = File.extname(path)[1..-1] 
        engine = options.delete(:engine)
        engine = format and path.chomp!(".#{format}") if engine.nil? && Tilt.mappings.keys.include?(format)
        
        # Check if I18n/GetText extension is enabled 
        search_locales = respond_to?(:locale)
        
        # Fetch template from cache
        resolve_options = [settings.views, path, content_type, engine, (locale if search_locales)].compact 
        resolved = settings.resolved_views[resolve_options]
        
        unless resolved
          helpers = Padrino::Rendering::Helpers
          options = Padrino::Rendering::DEFAULT_OPTIONS.merge(options)
          strict = options[:strict_format]
          
          # Collect list of all possible views available for project
          views = Padrino.view_files.dup
          views.unshift(v = options.delete(:views), helpers.glob_views(v)) if options[:views]

          views.each do |dir, files|
            # Skip all templates which not matches to specified explicit engine
            files = files.map {|file|
              ext = File.extname(file)[1..-1]
              [file.sub(/^\/+/, '').chomp(".#{ext}"), ext] if file =~ /^#{path}/ and (!engine or ext.to_s == engine.to_s)
            }.compact
            
            # Search for template with forced locale first
            if search_locales
              resolved = \
                files.find {|f,e| f == [path, locale, content_type].join('.') } ||
                files.find {|f,e| f == [path, locale].join('.') && valid_content_type? && !strict }
            end
            
            # Search for other matching templates
            resolved ||= \
              files.find {|f,e| f == [path, content_type].join('.') } ||
              files.find {|f,e| f == path && valid_content_type? && !strict }

            if resolved
              # Fit result to valid format 
              resolved[0] = Pathname.new(File.join(dir, resolved.join('.')))
              resolved[0] = resolved[0].relative_path_from(settings.views).to_s.to_sym
              resolved[1] = resolved[1].to_sym
              break
            end
          end
          
          if !resolved && options[:raise_exceptions]
            raise Padrino::Rendering::TemplateNotFound, "Template '#{path}' could not be located in '#{views.keys.join('; ')}'!" 
          else
            settings.resolved_views[resolve_options] = resolved 
          end
        end
        
        resolved
      end
      private :resolve_template
      
      def valid_content_type? # :nodoc
        [:html, :plain].include?(content_type)
      end
      private :valid_content_type?
      
      def content_type(type=nil, params={}) # :nodoc:
        type.nil? ? @_content_type : super(type, params)
      end

    end # InstanceMethods
  end # Rendering

  class << self
    ##
    # Returns list of root view directories for all mounted applications. 
    # 
    def view_paths
      @view_paths ||= mounted_apps.values.map {|app| 
        app.views if app.respond_to?(:views) 
      }.compact
    end
    
    ##
    # Returns list of all found view files in all mounted applications. 
    #
    def view_files
      @view_files ||= Dictionary[*view_roots.each {|path| Rendering::Helpers.glob_views(path) }]
    end
    
    alias :base_reset! :reset!
    
    def reset! # :nodoc:
      base_reset!
      @view_files = nil
      @view_paths = nil
      @resolved_views = nil
    end
  end # << self
end # Padrino
