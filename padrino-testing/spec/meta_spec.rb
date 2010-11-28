require File.expand_path('../spec_helper', __FILE__)

describe Padrino::Testing::Meta do
  describe "#inline_module" do
    context "no block given" do
      it "creates empty module" do
        inline_module.should be_kind_of(Module)
      end
    end
    
    context "given block" do
      it "evaluates it in created module" do
        mod = inline_module {def some_test_method; "Fooobar!"; end} 
        mod.public_methods.should include("some_test_method")
      end
    end
  end

  describe "#inline_klass" do
    context "no block given" do
      it "creates empty class" do
        inline_class.new.should be_kind_of(Object)
      end
    end
    
    context "given base class" do
      it "creates class based on" do
        inline_class(Array).new.should be_kind_of(Array)
      end
    end
    
    context "given block" do
      it "creates class with evaluated given block" do
        klass = inline_class { def some_test_method; "Fooobar!"; end }
        klass.public_methods.should include("some_test_method")
      end
    end
  end
end
