require 'mocha'
require 'rspec'
require 'padrino'

RSpec.configure do |conf|
  conf.include Padrino::Testing
  conf.mock_with :mocha
  conf.exclusion_filter = { 
    # the Ruby version filter...
    :ruby => lambda { |version| 
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) 
    },
    # library availability filter...
    :if_available => lambda { |lib|
      begin
        require lib
        false
      rescue LoadError
        true
      end
    },
  }
end
