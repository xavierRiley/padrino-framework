module Padrino
  ##
  # Object of this class keeps all directives to mount given application
  # on to Padrino cluster.
  #
  class Mountable
    attr_reader :cluster, :app, :path, :host, :port, :name
    
    def initialize(app)
      @app = app
    end
    
    ##
    # Mount application on to given path.
    #
    def to(path)
      @path = "^/#{path}(.*)".gsub(%r{^\^//}, "^/")
      return self
    end
    
    ##
    # Mount application with given name.
    #
    def as(name)
      @name = name
      return self
    end
    
    ##
    # Bind your application to given host (with port). 
    #
    # ==== Examples
    #
    #   bind("host.pl")
    #   bind("host.pl:8080")
    #   bind("*:8080")
    #   bind("host.pl:*")
    #   bind("*.host.pl")
    #
    def bind(url)
      @host, @port = url.split(":")
      @host = @host.to_s.gsub('.', '\.').gsub('*', '.*').sub(/.*/, '^\\0$') if @host
      @port = @port.to_s.gsub('*', '.*').sub(/.*/, '^\\0$') if @port
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
      mountables << (mountable = Mountable.new(app))
      mountable
    end
    
    def call(env)
      mountable, match = nil, nil
      path, script, host, port, name = env.values_at('PATH_INFO', 'SCRIPT_NAME', \
        'HTTP_HOST', 'SERVER_PORT', 'SERVER_NAME')

      unless mountable = cache["(#{host}|#{name}):#{port}#{path}"]
        matrix.each do |mnt|
          next if mnt.host && !(host.match(mnt.host) || name.match(mnt.host))
          next if mnt.port && !(port.to_s.match(mnt.port))
          next if mnt.path.nil? || !(match = path.match(mnt.path))
          cache["(#{host}|#{name}):#{port}#{path}"] = mountable = mnt and break
        end
      end
      
      if mountable
        match ||= path.match(mountable.path)
        env['SCRIPT_NAME'] = script + match[0]
        env['PATH_INFO'] = "/#{match[-1]}".gsub(%r{^//}, "/")
        env['rack.app.name'] = mountable.name
        return mountable.app.call(env) if mountable.app.respond_to?(:call)
      end
      
      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]
    end
    
    private
    
    def cache
      @cache = {}
    end
    
    def matrix
      unless @matrix
        @matrix = {}
        mountables.each do |m| 
          h = @matrix[m.host || "*"] ||= {}
          p = h[m.port || "*"] ||= {}
          p[m.path] = m
        end
        @matrix.each do |hk,hv|
          hv.each do |pk, pv| 
            hv[pk] = pv.to_a
            hv[pk].sort! do |x,y|
              ypath, xpath = y.last.path.gsub("^/", ""), x.last.path.gsub("^/", "")
              ypath.size <=> xpath.split(/\//).size 
            end
          end
          @matrix[hk] = hv.to_a
          @matrix[hk].sort! {|x,y| y.first.size <=> x.first.size }
        end
        @matrix = @matrix.to_a
        @matrix.sort! {|x,y| y.first.size <=> x.first.size }
        @matrix = @matrix.flatten.find_all {|x| x.kind_of?(Padrino::Mountable) }
      end
      @matrix
    end
  end # Cluster
end # Padrino
