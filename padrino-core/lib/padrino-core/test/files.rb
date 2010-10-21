require 'fileutils'

module Padrino
  module Test
    module Files
      ##
      # Expands given paths. 
      #
      # ==== Examples
      # 
      #   expand_path("/home/nu7hatch", "foo/bar")    # => "/home/nu7hatch/foo/bar"
      #   expand_path("/home/nu7hatch", "../foo/bar") # => "/home/foo/bar"
      #
      def expand_path(root, *parts)
        File.expand_path(File.dirname(root), *parts)
      end
      
      ##
      # Do something in context of given directory.
      #
      # ==== Examples
      #
      #   within_dir __FILE__, "tmp/foo" do
      #     Dir.pwd # => __FILE__ + "/tmp/foo"
      #   end
      #
      def within_dir(root, *parts)
        pwd = Dir.pwd
        dir = expand_path(root, *parts)
        remove = false
        unless File.exists?(dir)
          remove = File.join(parts).split("/").first
          FileUtils.mkdir_p(dir)
        end
        Dir.chdir(dir)
        yield
      ensure
        FileUtils.rm_rf(remove) if remove
        Dir.chdir(pwd)
      end
      
    end # Files
  end # Test
end # Padrino
