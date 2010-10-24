require File.expand_path('../spec_helper', __FILE__)

describe Padrino::Cluster do
  subject do
    Padrino::Cluster
  end
  
  describe "#new" do
    context "when no block given" do
      it "returns itself only" do
        subject.new.should be_kind_of(Padrino::Cluster)
      end
    end
    
    context "given block" do
      it "evaluates in wihinin cluster context" do
        cluster = subject.new { @result = "test" }
        cluster.instance_variable_get('@result').should == "test"
      end
    end
  end
  
  describe "#mount" do
    before do
      @cluster = subject.new
      @result = @cluster.mount(@app = proc {})
    end
    
    it "adds given rack application to list of mounted apps" do
      @cluster.mountables.should include(@result)
    end
    
    it "returns newly created mountable" do
      @result.should be_kind_of(Padrino::Mountable)
    end
  end
  
  describe "routing" do
    before do  
      headers = {"Content-Type"=>"text/html"}
      cluster = subject.new
      cluster.mount(proc {|env| [200, headers, "1"]}).to("/")
      cluster.mount(proc {|env| [200, headers, "2"]}).to("/path")
      cluster.mount(proc {|env| [200, headers, "3"]}).to("/path").bind("host.pl")
      cluster.mount(proc {|env| [200, headers, "4"]}).to("/").bind("host.com:8080")
      cluster.mount(proc {|env| [200, headers, "5"]}).bind("*.host.com").to("/")
      cluster.mount(proc {|env| [200, headers, "6"]}).bind("host.com:*").to("/")
      set_app(cluster)
    end
    
    it "routes properly to simple root path" do
      request("/").body.should == "1"
    end
    
    it "routes properly to given path" do
      request("/path/bar/com").body.should == "2"
    end
    
    it "routes properly to given host and path" do
      request("/path/bar/com", "HTTP_HOST" => "host.pl").body.should == "3"
    end
    
    it "routes properly to given host and port" do
      request("/foo/bar", "HTTP_HOST" => "host.com", "SERVER_PORT" => 8080).body.should == "4"
    end
    
    it "routes properly to given host with wildcard" do
      request("/", "HTTP_HOST" => "test.host.com").body.should == "5"
    end
    
    it "routes properly to given port with wildcard" do
      request("/", "HTTP_HOST" => "host.com", "SERVER_PORT" => 994).body.should == "6"
    end
  end
end

describe Padrino::Mountable do
  subject do
    Padrino::Mountable
  end
  
  before do
    @mountable = subject.new(@app = proc {})
  end

  describe "#new" do
    it "sets given app" do
      @mountable.app.should == @app
    end
  end
  
  context "#as" do
    before do
      @result = @mountable.as(:test)
    end
    
    it "sets app name" do
      @mountable.name.should == :test
    end
    
    it "returns itself" do
      @result.should == @mountable
    end
  end
  
  describe "#to" do
    before do
      @result = @mountable.to("/test")
    end
    
    it "sets app path" do
      @mountable.path.should == "^/test(.*)"
    end
    
    it "returns itself" do
      @result.should == @mountable
    end
  end
  
  describe "#bind" do
    context "when simple host given" do
      before do
        @result = @mountable.bind("foo.bar.com:8080")
      end
      
      it "sets app host" do
        @mountable.host.should == '^foo\.bar\.com$'
      end
      
      it "sets app port" do
        @mountable.port.should == '^8080$'
      end
    
      it "returns itself" do
        @result.should == @mountable
      end
    end
    
    context "when wildcarded host given" do
      before do
        @result = @mountable.bind("*.bar.com:*")
      end
      
      it "sets app host" do
        @mountable.host.should == '^.*\.bar\.com$'
      end
      
      it "sets app port" do
        @mountable.port.should == '^.*$'
      end
    end
  end
end
