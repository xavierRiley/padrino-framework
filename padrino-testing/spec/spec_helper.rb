require File.expand_path('../../../load_paths', __FILE__)

require 'mocha'
require 'rspec'
require 'padrino'
require 'padrino-testing'

RSpec.configure do |conf|
  conf.include Padrino::Testing
  conf.mock_with :mocha
  conf.exclusion_filter = { 
    :ruby => lambda { |version| 
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) 
    }
  }
end
