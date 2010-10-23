namespace :routes do
  desc "List all named routes in the project. List can be filtered by given [query]"
  task :default, :query, :needs => :environment do |t, args|
    # TODO...
  end
  
  desc "List all named routes from given [app]"
  task :app, :app, :needs => :environment do |t, args|
    # TODO...
  end
end
