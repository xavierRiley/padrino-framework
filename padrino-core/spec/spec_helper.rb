$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'mocha'
require 'rspec'
require 'rack/test'

require 'padrino-core'
require 'padrino-core/test'

RSpec.configure do |conf|
  conf.mock_with :mocha
  conf.include Rack::Test::Methods
  conf.include Padrino::Test::Meta
  conf.include Padrino::Test::IO 
end
