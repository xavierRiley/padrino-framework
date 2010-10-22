module Padrino
  module Test
    module Rack
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
