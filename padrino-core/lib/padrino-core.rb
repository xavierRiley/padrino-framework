require 'pathname'
require 'sinatra/base'
#require 'padrino-core/support_lite' unless defined?(SupportLite)

#FileSet.glob_require('padrino-core/application/*.rb', __FILE__)
#FileSet.glob_require('padrino-core/*.rb', __FILE__)

# Defines our Constants
#PADRINO_ENV  = ENV["PADRINO_ENV"]  ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
#XXX: doesn't work
#PADRINO_ROOT = ENV["PADRINO_ROOT"] ||= File.dirname(Padrino.first_caller) unless defined?(PADRINO_ROOT)

module Padrino
  autoload :Test,      "padrino-core/test"
  autoload :Server,    "padrino-core/server"
  autoload :Cluster,   "padrino-core/cluster"
  autoload :Mountable, "padrino-core/cluster"
  
  class ApplicationLoadError < RuntimeError #:nodoc:
  end
  
  class Application < Sinatra::Application
  end

  class << self
    ##
    # Run the Padrino apps as a self-hosted server using: thin, mongrel, webrick 
    # in that order.
    #
    # ==== Examples
    #
    #   Padrino.run! 
    # ... will start server at localhost on port 3000 using the first found handler.
    #
    #   Padrino.run!(:Host => "localhost", :Port => "4000", :server => "mongrel")
    # ... will start server at localhost on port 4000 using mongrel handler.
    # 
    def run!(options={})
      Server.start(options)
    end
    
    ##
    # Manipulates root path of current Padrino project.
    #
    # ==== Examples
    #   
    #   Padrino.root("/home/my/app")
    #   Padrino.root # => "/home/my/app"
    #   Padrino.root.join("config", "settings.yml") # => "/home/my/app/config/settings.yml"
    #
    #
    # TODO: add first caller by default
    def root(path=nil)
      @root = Pathname.new(path) if path
      @root
    end

    ##
    # Helper method that returns current Padrino environment.
    #
    def env(env=nil)
      @env = env.to_s if env
      @env ||= ENV["PADRINO_ENV"] || ENV["RACK_ENV"] || "development"
    end

    ##
    # Returns the resulting rack builder powered by Padrino cluster. 
    #
    # TODO: Somewhere we have to raise error abount no mounted apps. 
    def application
      @application ||= Rack::Builder.new { run Cluster.new }
    end
    
    ##
    # Mounts given rack application on to Padrino apps cluster. 
    #
    # ==== Examples
    #
    #   Padrino.mount(FirstApp).to("/")
    #   Padrino.mount(SecondApp).bind("host.com").to("/")
    #   Padrino.mount(ThirdApp).to("/path").as(:third_one)
    #
    # See <tt>Padrino::Cluster</tt> for details.
    #
    def mount(app)
      application.to_app.mount(app)
    end
    
    ##
    # Default encoding to UTF8.
    #
    def set_encoding
      unless RUBY_VERSION < '1.9'
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = Encoding::UTF_8
      else
        $KCODE='u'
      end
      nil
    end
  end # self
end # Padrino

=begin
    ##
    # Returns the used $LOAD_PATHS from padrino
    #
    def load_paths
      %w(
        lib
        models
        shared
      ).map { |dir| root(dir) }
    end

    ##
    # Return bundle status :+:locked+ if .bundle/environment.rb exist :+:unlocked if Gemfile exist
    # otherwise return nil
    #
    def bundle
      return :locked   if File.exist?(root('.bundle/environment.rb'))
      return :unlocked if File.exist?(root("Gemfile"))
    end
  end # self
end # Padrino
=end
