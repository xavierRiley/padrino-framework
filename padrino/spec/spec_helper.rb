$LOAD_PATH.unshift(File.dirname(__FILE__))

['', '-core', '-gen', '-helpers', '-mailer', '-cache', '-admin'].each do |component|
  $LOAD_PATH.unshift(File.expand_path("../../../padrino#{component}/lib", __FILE__))
end

require 'rubygems'
require 'mocha'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.mock_with :mocha
end
