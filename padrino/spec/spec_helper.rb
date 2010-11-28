require File.expand_path('../../../load_paths', __FILE__)

require 'mocha'
require 'rspec'
require 'rack/test'

RSpec.configure do |conf|
  conf.mock_with :mocha
end
