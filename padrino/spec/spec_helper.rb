$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'mocha'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.mock_with :mocha
end
