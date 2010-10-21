require File.join(File.dirname(__FILE__), 'spec_helper')

module Rack::Handler
  class Mock
    extend Test::Unit::Assertions

    def self.run(app, options={})
      assert_equal 9001, options[:Port]
      assert_equal 'foo.local', options[:Host]
      yield new
    end

    def stop
    end
  end

  register 'mock', 'Rack::Handler::Mock'
  Padrino::Server::SUPPORTED_HANDLERS << 'mock'
end

describe "Padrino's Rack server" do
    
end
