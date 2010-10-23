require File.join(File.dirname(__FILE__), 'spec_helper')

describe Padrino::Test::Rack do
  describe "#set_app" do
    it "sets current test application " do
      set_app(test_app = proc {})
      app.instance_variable_get("@app").should == test_app
    end
  end
  
  describe "#app" do
    context "when test application is set" do
      before do
        set_app(proc {})
      end
    
      if "returns current test application wrapped by Rack::Lint" do
        app.should be_kind_of(Rack::Lint)
      end
    end
    
    context "when there is no test application set" do
      before do
        set_app(nil)
      end
      
      it "returns nil" do
        app.should_not be
      end
    end
  end
  
  describe "#within_app" do
    context "given block" do
      before :each do 
        @test_app = proc {}
        @result   = nil
      end
      
      it "executes it in given app context" do
        within_app(test_app) { @result = app }
        @result.should == @test_app
      end
      
      it "reverts back to previous app after execute" do
        app.should_not == test_app
      end
    end
  end
    
  describe "#mock_app" do
    context "given base class" do
      before do
        @mock_app = mock_app(Sinatra::Application) { get("/foo") { "Hello world!" } }
      end
      
      it "produces application based on it" do
        @mock_app.should be_kind_of(Sinatra::Application)
      end
      
      it "sets produced app for rack tests" do
        app.should == @mock_app
      end
      
      it "allows to use rack test helpers on it" do
        get("/foo").body.should == "Hello world!"
      end
    end
    
    context "no base class given" do
      before do
        @mock_app = mock_app {}
      end
      
      it "produces application based on Padrino::Application" do
        @mock_app.should be_kind_of(Padrino::Application)
      end
    end
  end
end
