module Padrino
  module Test
    module Rack
    
      def mock_app(&block)
      
      end
      
      def within_app(app)
        tmp = self.app
        set_app(app)
        yield 
      ensure
        set_app(tmp)
      end
      
      def set_app(app)
        @app = app
      end
      
      def app
        @app
      end
      
    end # Rack
  end # Test
end # Padrino
