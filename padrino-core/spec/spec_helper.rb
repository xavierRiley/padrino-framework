$LOAD_PATH.unshift(File.dirname(__FILE__))

['', '-core', '-gen', '-helpers', '-mailer', '-cache', '-admin'].each do |component|
  $LOAD_PATH.unshift(File.expand_path("../../../padrino#{component}/lib", __FILE__))
end

require 'rubygems'
require 'mocha'
require 'rspec'
require 'rack/test'
require 'padrino'

RSpec.configure do |conf|
  conf.mock_with :mocha
  conf.exclusion_filter = { 
    :ruby => lambda {|version| !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) }
  }
  
  conf.include Rack::Test::Methods
  conf.include Padrino::Test::Meta
  conf.include Padrino::Test::IO
  conf.include Padrino::Test::Files 
  conf.include Padrino::Test::Rack
  conf.include Padrino::Test::Runtime
end
