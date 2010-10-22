module Padrino
  module Test
    module Runtime
      ## 
      # Execute given block with empty ARGV. 
      #
      # ==== Example
      #
      #   p ARGV 
      #   without_argv do 
      #     p ARGV
      #   end
      #
      # will produce:
      #
      #   ["--foo", "bar"]
      #   []
      #
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
