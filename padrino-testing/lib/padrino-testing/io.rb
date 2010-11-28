require 'stringio'

module Padrino
  module Testing
    module IO
      ## 
      # Capture standard output and error streams.
      #
      # ==== Examples
      #
      #   out, err = capture_output do 
      #     $stderr.puts "Hello..."
      #     $stdout.puts "World!"
      #   end
      #
      #   out # => "Hello..."
      #   err # => "World!"
      #
      def capture_output
        out, err = StringIO.new, StringIO.new
        begin
          $stdout, $stderr = out, err
          yield
        rescue
          $stdout, $stderr = STDOUT, STDERR
        end
        [out.string, err.string]
      end
      alias :silence_output :capture_output
      
      ##
      # Decrases interpreter verbosity.
      #
      def silence_warnings
        verbose, $VERBOSE = $VERBOSE, nil
        yield
      ensure
        $VERBOSE = verbose
      end
      
      ##
      # Replace standard input with faked one StringIO.
      #
      # ==== Examples
      #
      #   fake_stdin "Hello...", "World!" do
      #     gets.chomp # => "Hello..."
      #     gets.chomp # => "World!"
      #   end
      #
      def fake_stdin(*args)
        begin
          $stdin = StringIO.new
          $stdin.puts(args.shift) until args.empty?
          $stdin.rewind
          yield
        ensure
          $stdin = STDIN
        end
      end
      
    end # IO
  end # Testing
end # Padrino
