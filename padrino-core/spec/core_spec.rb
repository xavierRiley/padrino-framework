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
end
