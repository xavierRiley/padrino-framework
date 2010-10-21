require 'fileutils'
require 'pathname'

module Padrino
  module Test
    module Files
      ##
      # Expands given paths. 
      #
      # ==== Examples
      # 
      #   path_to("/home/nu7hatch", "foo/bar")    # => "/home/nu7hatch/foo/bar"
      #   path_to("/home/nu7hatch", "../foo/bar") # => "/home/foo/bar"
      #
      def path_to(root, *parts)
        File.expand_path(File.join(*parts), File.dirname(root))
      end
      
      ##
      # Do something in context of given directory.
      #
      # ==== Examples
      #
      #   within_dir __FILE__, "tmp/foo" do
      #     # ... do something here ...
      #   end
      #
      def within_dir(root, *parts)
        dir = path_to(root, *parts)
        remove = false
        unless File.exists?(dir)
          remove = path_to(root, File.join(parts).split("/").first)
          FileUtils.mkdir_p(dir)
        end
        yield(dir)
      ensure
        FileUtils.rm_rf(remove) if remove
      end
      
    end # Files
  end # Test
end # Padrino
