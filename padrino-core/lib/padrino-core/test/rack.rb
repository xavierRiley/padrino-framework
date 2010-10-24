require 'rack'
require 'rack/test'

module Padrino
  module Test
    module Rack
      include ::Rack::Test::Methods
    
      ##
      # Prepares mock application based on given class. Given class have to 
      # inherits from <tt>Sinatra::Application</tt> based.
      #
      # ==== Examples
      #
      #   mock_app do
      #     get "/hello" do
      #       "Hello world!"
      #     end
      #   end
      #
      #   mock_app(Sinatra::Application) do
      #     ...
      #   end
      #
      def mock_app(base=Padrino::Application, &block)
        set_app(Sinatra.new(base, &block))
      end
    
      ##
      # Do something in context of given application.
      #
      # ==== Examples
      #
      #   within_app(MyFakeApp.new) do
      #     get("/hello")
      #     post("/world")
      #   end
      #
      def within_app(app)
        tmp = self.app
        set_app(app)
        yield 
      ensure
        set_app(tmp)
      end
      
      ##
      # Set given app for Rack tests.
      # 
      def set_app(app)
        @app = app
      end
      
      ##
      # Returns current Rack test app.
      #
      def app
        @app
      end
      
    end # Rack
  end # Test
end # Padrino
