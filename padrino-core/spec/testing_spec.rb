require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Padrino's test helpers" do
  context "for metaprogramming" do
    subject do
      klass = Class.new(Object)
      klass.send :include, Padrino::Testing::Metaprogramming
      klass.new
    end
  
    context "#inline_module" do
      it "should create empty module when no block given" do
        subject.inline_module.should be_kind_of Module
      end
      
      it "should create module with evaluated given block" do
        subject.inline_class { 
          def some_test_method; "Fooobar!"; end 
        }.public_methods.should include "some_test_method"
      end
    end

    context "#inline_klass" do
      it "should create empty class when no block given" do
        subject.inline_module.should be_kind_of Module
      end
      
      it "should create class with evaluated given block" do
        subject.inline_class { 
          def some_test_method; "Fooobar!"; end 
        }.public_methods.should include "some_test_method"
      end
    end
  end
end
