require File.expand_path('../spec_helper', __FILE__)

describe Padrino::Testing::Rack do
  describe "#set_app" do
    it "sets current test application " do
      set_app(test_app = proc {})
      app.should == test_app
    end
  end
  
  describe "#app" do
    context "when test application is set" do
      before do
        set_app(@test_app = proc {})
      end
    
      it "returns current test application" do
        app.should == @test_app
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
        within_app(@test_app) { @result = app }
        @result.should == @test_app
      end
      
      it "reverts back to previous app after execute" do
        app.should_not == @test_app
      end
    end
  end
    
  describe "#mock_app" do
    context "given base class" do
      it "produces application based on it" do
        Sinatra.expects(:new).with(Sinatra::Application)
        mock_app(Sinatra::Application) { }
      end
      
      it "allows to use rack test helpers on it" do
        mock_app(Sinatra::Application) { get("/foo") { "Hello world!" } }
        get("/foo").body.should == "Hello world!"
      end
    end
    
    context "no base class given" do
      before do
        mock_app {}
      end
      
      it "produces application based on Padrino::Application" do
        #app.should be_kind_of(Padrino::Application)
      end
    end
  end
end
