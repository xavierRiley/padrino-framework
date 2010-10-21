module Padrino
  module Test
    module Runtime
      
      def without_argv
        argv = ARGV
        ARGV.replace([])
        yield
      ensure
        ARGV.replace(argv)
      end
      
    end # Runtime
  end # Test
end # Padrino
