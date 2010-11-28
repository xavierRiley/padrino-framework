require 'fileutils'
require 'pathname'

module Padrino
  module Testing
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
      
      ##
      # Creates temporary view file with given content. 
      #
      # ==== Examples
      #
      #   with_view(__FILE__, "test/foo.html", "Test!") { ... }
      #   with_view(__FILE__, "test/foo.html.haml", "Test!")  { ... }
      #   with_view(__FILE__, "test/foo.pl.html", "Test!") { ... }
      #
      def with_view(root, path, content, options={})
        within_dir(root, "views/layouts") do
          path  = "/views/#{path}"
          path += ".erb" unless options[:format].to_s =~ /(haml|rss|atom)$/ 
          path += ".builder" if options[:format].to_s =~ /(rss|atom)$/
          File.open(file = File.expand_path("../#{path}", root), 'w') do |f| 
            f.write content 
          end
          yield(file)
        end
      end
      alias :with_layout :with_view
      
    end # Files
  end # Testing
end # Padrino
