module Padrino
  ##
  # This is used for bootstrap with padrino rake tasks. It should be executed
  # in project's rakefile.
  #
  def self.load_rake_tasks
    rake_tasks = []
    rake_tasks << Dir.glob(File.join(File.dirname(__FILE__), "tasks/**/*.rake"))
    rake_tasks << Dir.glob(Padrino.root("tasks/**/*.rake"))
    rake_tasks << Dir.glob(Padrino.root("lib/tasks/**/*.rake"))
    rake_tasks << Dir.glob(Padrino.root("app/tasks/**/*.rake"))
    rake_tasks.flatten.compact.uniq.each {|task| load(task) }
  end
  
end # Padrino
