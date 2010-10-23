module Padrino
  ##
  # Object of this class keeps all directives to mount given application
  # on to Padrino cluster.
  #
  class Mountable
    attr_reader :cluster, :app, :path, :host, :port, :name
    
    def initialize(cluster, app)
      @cluster, @app = cluster, app
      @cluster.mountables << self
    end
    
    def to(path)
      @path = "^/#{path}(.*)".gsub(%r{^\^//}, "^/")
      return self
    end
    
    def as(name)
      @name = name
      return self
    end
    
    def bind(url)
      @host, @port = url.split(":")
      @host = @host.gsub('*', '.*').gsub('.', '\.')
      return self
    end
  end # Mountable
  
  ##
  # This Rack cluster helps with mounting many rack applications into one
  # big application. 
  # 
  # ==== Examples
  #
  #   Rack::Builder.new do
  #     run Rack::Cluster.new do
  #       mount(MyFirstApp).bind("myhost.com").to("/").as(:my_first_app)
  #       mount(MySecondApp).to("/path").as(:second_one)
  #       mount(MyThirdApp).bind("*.myhost.com").to("/")
  #       mount(MyFourthApp).bind("myhost.com:8080").to("/path")
  #     end
  #   end
  #
  class Cluster
  
    def initialize(&block)
      instance_eval(&block) if block_given?
    end
    
    ##
    # All mountable apps with mount directives.
    #
    def mountables
      @mountables ||= []
    end
    
    ##
    # It produces mountable from given rack application. 
    #
    # ==== Examples
    #
    #   mount(proc {|env| ... })
    #   mount(Sinatra::Application.new)
    #   mount(Padrino::Application.new)
    #   mount(MyApp)
    #
    def mount(app)
      Mountable.new(self, app)
    end
    
    ##
    # This cache increases cluster performance, by storing already resolved
    # routes (host, port and base path). 
    #
    def cache
      @cache = {}
    end
    
    def call(env)
      mountable, match = nil, nil
      path, script, host, port, name = env.values_at \
        'PATH_INFO', 'SCRIPT_NAME', 'HTTP_HOST', 'SERVER_PORT', 'SERVER_NAME'

      unless mountable = cache["#{host}:#{port}#{path}"]
        mountables.each do |mnt|
          next if mnt.host && (!host.match(mnt.host) || !name.match(mnt.host))
          next if mnt.port && (mnt.port.to_i != port.to_i)
          next if mnt.path.nil? || !(match = path.match(mnt.path))
          cache["#{host}:#{port}#{path}"] = mnt and break
        end
      end
      
      if mountable
        match ||= path.match(mountable.path)
        env['SCRIPT_NAME'] = script + match[0]
        env['PATH_INFO'] = "/#{match[-1]}".gsub(%r{^//}, "/")
        env['rack.app.name'] = mountable.name
        return mountable.app.call(env)
      end
      
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]
    end
  end # Cluster
end # Padrino
