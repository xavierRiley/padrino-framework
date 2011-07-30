module Padrino
  ##
  # Run the Padrino apps as a self-hosted server using:
  # thin, mongrel, webrick in that order.
  #
  # ==== Examples
  #
  #   Padrino.run! # with these defaults => host: "localhost", port: "3000", adapter: the first found
  #   Padrino.run!(:host => "localhost", :port => "4000", :server => "mongrel")
  #   Padrino.run!(:reload => true)
  #
  def self.run!(options={})
    unless options.delete(:reload)
      Padrino.load!
      Padrino::Server.start(Padrino.application, options)
      return Padrino.application
    end

    Padrino.load_core!

    loop do
      @int       = false
      @first_run = true
      @pid       = fork { Padrino.load_application!; Padrino::Server.start(Padrino.application) }
      @mtimes  ||= {}

      trap(:HUP){ puts ">> Performing restart"; @int = true }

      %w(INT KILL QUIT TERM).each do |signal|
        trap(signal) do
          if @int
            puts "<= Padrino has ended his set (crowd applauds)"
            exit
          else
            @int = true
            puts ">> Press Interrupt a second time to really quit."
            sleep 1.5
            puts ">> Performing restart"
          end
        end
      end

      until @int do
        Dir[Padrino.root("**/*.rb")].sort.each do |file|
          if !@mtimes.has_key?(file)
            logger.debug "Detected a new file: #{file}"
            Process.kill(:HUP, Process.pid)
            Process.kill(:INT, @pid)
            @restart = true
          elsif @mtimes[file] < File.mtime(file)
            logger.debug "Detected modified file #{file}"
            Process.kill(:HUP, Process.pid)
            Process.kill(:INT, @pid)
            @restart = true
          end unless @first_run
          @mtimes[file] = File.mtime(file)
        end

        @first_run = false
        sleep 0.2
      end

      Process.waitpid(@pid)
    end
  rescue NotImplementedError
    puts "=> Reloading is not available for your env."
    Server.start(Padrino.application, options)
  end

  ##
  # This module build a Padrino server
  #
  class Server < Rack::Server
    # Server Handlers
    Handlers = [:thin, :mongrel, :webrick]

    def self.start(app, opts={})
      options = {}.merge(opts) # We use a standard hash instead of Thor::CoreExt::HashWithIndifferentAccess
      options.symbolize_keys!
      options[:Host] = options.delete(:host) || '0.0.0.0'
      options[:Port] = options.delete(:port) || 3000
      options[:AccessLog] = []
      if options[:daemonize]
        options[:pid] = options[:pid].blank? ? File.expand_path('tmp/pids/server.pid') : opts[:pid]
        FileUtils.mkdir_p(File.dirname(options[:pid]))
      end
      options[:server] = detect_rack_handler if options[:server].blank?
      new(options, app).start unless options.delete(:reload)
    end

    def initialize(options, app)
      @options, @app = options, app
    end

    def start
      puts "=> Padrino/#{Padrino.version} has taken the stage #{Padrino.env} at http://#{options[:Host]}:#{options[:Port]}"
      [:INT, :TERM, :KILL].each { |sig| trap(sig) { exit } }
      super
    end

    def app
      @app
    end
    alias :wrapped_app :app

    def options
      @options
    end

    private
      def self.detect_rack_handler
        Handlers.each do |handler|
          begin
            return handler if Rack::Handler.get(handler.to_s.downcase)
          rescue LoadError
          rescue NameError
          end
        end
        fail "Server handler (#{Handlers.join(', ')}) not found."
      end
  end # Server
end # Padrino