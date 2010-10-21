require File.join(File.dirname(__FILE__), 'spec_helper')
require "rack"

PADRINO_ROOT = "" unless defined?(PADRINO_ROOT)

describe "Padrino's Rack server" do
  before do
    unless defined?(MockHandler)
      MockHandler = mock
      MockHandler.stubs(:name).returns("mock")
      Rack::Handler.register 'mock', 'MockHandler'
      Padrino::Server::SUPPORTED_HANDLERS << 'mock'
    end
  end
  
  def rackup(config)
    #capture_output do
      opts = { :config => config, :Port => 9001, :server => 'mock' }
      MockHandler.expects(:run).once
      Padrino.run!(opts)
    #end
  end
  
  subject do 
    Padrino::Server
  end
  
  context "on initialize" do
    it "should convert :host and :port params to rack consistent" do
      without_argv do
        srv = subject.new(:host => "test.host", :port => 9001)
        srv.options[:Host].should == "test.host"
        srv.options[:Port].should == 9001
        srv.options.should_not have_key :host
        srv.options.should_not have_key :port
      end
    end
    
    it "should set proper default options" do
      without_argv do
        srv = subject.new
        srv.options[:Host].should == "127.0.0.1"
        srv.options[:Port].should == 3000
        srv.options[:daemonize].should == false
        srv.options[:config].should == "config.ru"
      end
    end
  end
  
  context "on start" do
    it "should properly resolve app when given config.ru exists" do
      #app_path = path_to(__FILE__, "fixtures/apps/rackup-config")
      #srv = subject.new(:config => path_to(app_path, "config.ru"))
      #srv.app.should be_kind_of Rack::Builder
      #within_app(srv.app) { get("/hello").should == "Hello world!" }
    end
    
    it "should rack up config/boot.rb when config.ru doesn't exist" do
      #PADRINO_ROOT.replace(path_to(__FILE__, "fixtures/apps/rackup-boot"))
      #rackup(path_to(PADRINO_ROOT, "config.ru"))
    end
  end
end
