require 'rake'

Dir[File.join(File.dirname(__FILE__), "tasks/**/*.rake"].each do |task|
  load task
end
