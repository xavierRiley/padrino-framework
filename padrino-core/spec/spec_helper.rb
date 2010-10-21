$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'mocha'
require 'rspec'

require 'padrino-core'
require 'padrino-core/testing'

RSpec.configure do |conf|
  conf.mock_with :mocha 
end
