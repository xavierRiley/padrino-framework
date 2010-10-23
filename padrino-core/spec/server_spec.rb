require File.expand_path('../spec_helper', __FILE__)

describe Padrino::Server do
  subject do
    Padrino::Server
  end

  before do
    unless defined?(MockHandler)
      MockHandler = mock
      MockHandler.stubs(:name).returns("mock")
      Rack::Handler.register 'mock', 'MockHandler'
      Padrino::Server::SUPPORTED_HANDLERS << 'mock'
    end
  end
  
  context "#initialize" do
    it "converts :host and :port params to rack consistent :Host and :Port" do
      without_argv do
        srv = subject.new(:host => "test.host", :port => 9001)
        srv.options[:Host].should == "test.host"
        srv.options[:Port].should == 9001
        srv.options.should_not have_key :host
        srv.options.should_not have_key :port
      end
    end
    
    it "sets default options properly" do
      without_argv do
        srv = subject.new
        srv.options[:Host].should == "127.0.0.1"
        srv.options[:Port].should == 3000
        srv.options[:daemonize].should == false
        srv.options[:config].should == "config.ru"
      end
    end
  end
  
  context "#start" do
    context "when given config.ru exists" do
      it "is racking it up properly" do
        pending
        #app_path = path_to(__FILE__, "fixtures/apps/rackup-config")
        #srv = subject.new(:config => path_to(app_path, "config.ru"))
        #srv.app.should be_kind_of Rack::Builder
        #within_app(srv.app) { get("/hello").should == "Hello world!" }
      end
    end
    
    context "when given config.ru doesn't exist, and there is config/boot.rb" do
      it "is racking it up properly" do
        pending
        #PADRINO_ROOT.replace(path_to(__FILE__, "fixtures/apps/rackup-boot"))
        #rackup(path_to(PADRINO_ROOT, "config.ru"))
      end
    end
    
    context "when given config.ru doesn't exist, and there is no config/boot.rb" do
      it "is racking up Padrino.application" do
      
      end
    end
  end
end
