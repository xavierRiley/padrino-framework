module Padrino
  module Rake
    ##
    # It will load all project specific tasks from following dirs:
    #
    #   tasks/*.{rake,rb}
    #   lib/tasks/*.{rake,rb}
    #   app/tasks/*.{rake,rb}
    #
    def self.project_rake_files
      rake_files = []
      rake_files.concat Dir.glob(File.join(project_root, "tasks/*.{rake,rb}"))
      rake_files.concat Dir.glob(File.join(project_root, "lib/tasks/*.{rake,rb}"))
      rake_files.concat Dir.glob(File.join(project_root, "app/tasks/*.{rake,rb}"))
      rake_files.compact.uniq
    end
    
    def self.project_root
      File.dirname(::Rake.application.rakefile_location)
    end

  end # Rake
end # Padrino
