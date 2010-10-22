require 'rake'
require 'rake/tasklib'
require 'padrino'
require 'padrino/rake'

desc "Setting up the required environment"
task :environment do
  # TODO...
end

namespace :routes do
  desc "List all named routes in the project. List can be filtered by given [query]"
  task :routes, :query, :needs => :environment do |t, args|
    # TODO...
  end
  
  desc "List all named routes from given [app]"
  task :app, :app, :needs => :environment do |t, args|
    # TODO...
  end
end

# Load project specific rake files. 
Padrino::Rake.project_rake_files.each |rake_file|
  load rake_file
end
