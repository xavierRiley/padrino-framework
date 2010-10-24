require File.expand_path('../spec_helper', __FILE__)

describe Padrino do
  subject do
    Padrino
  end

  describe "#root" do
    context "when path given" do
      it "sets it as project root" do
        subject.root("/home/test/foo")
        subject.root.to_s.should == "/home/test/foo"
      end
    end
    
    context "without args" do
      context "when root path has been already set" do
        before do
          subject.root("/home/test/foo")
        end
        
        it "returns Pathname object" do
          subject.root.should be_kind_of Pathname
        end
        
        it "pathname raw path is proper" do
          subject.root.to_s.should == "/home/test/foo"
        end
      end
    
      context "when root path has not been set yet" do
        before do
          subject.instance_variable_set("@path", nil) 
        end
        
        it "uses first caller's directory as project root" do
          pending
        end
      end
    end
  end
  
  describe "#env" do
    after :all do
      subject.env(:test)
    end
    
    context "when env given" do
      it "sets it as project environment" do
        subject.env(:production)
        subject.env.should == "production"
      end
    end
    
    context "without args" do
      context "when env has been already set" do
        before do
          subject.env(:test)
        end
  
        it "returns name of current env" do
          subject.env.should == "test"
        end
      end
      
      context "when env has not been set yet" do
        before :each do
          subject.instance_variable_set("@env", nil)
        end
        
        it "is development by default" do
          subject.env.should == "development"
        end
        
        it "ports to RACK_ENV if present" do
          ENV["RACK_ENV"] = "rack-env"
          subject.env.should == "rack-env"
        end
        
        it "ports to PADRINO_ENV if present" do
          ENV["PADRINO_ENV"] = "padrino-env"
          subject.env.should == "padrino-env"
        end
      end
    end
  end
  
  describe "#run!" do
    it "starts server with given options" do
      Padrino::Server.expects(:start).with(:host => "localhost").once
      subject.run!(:host => "localhost")
    end
  end
  
  describe "#application" do
    it "returns rack app with Padrino cluster enabled" do
      subject.application.should be_kind_of Rack::Builder
      subject.application.to_app.should be_kind_of Padrino::Cluster
    end
  end
  
  describe "#mount" do
    it "mounts given application on to project cluster" do
      subject.application.to_app.expects(:mount).once.with(instance_of(Proc))
      subject.mount(proc {})
    end
  end
  
  describe "#set_encoding" do
    it "sets properly interpreter encoding to UTF8", :ruby => "1.8" do
      pending
    end
    
    it "sets properly interpreter encoding to UTF8", :ruby => "1.9" do
      pending
    end
  end
  
  describe "#applications" do
    it "returns hash with mounted apps" do
      subject.instance_variable_set("@application", nil)
      subject.mount(app = proc {}).to("/").as(:test)
      subject.mounted_apps[:test].should == app
    end
  end
end
