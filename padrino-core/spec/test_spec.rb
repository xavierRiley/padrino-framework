require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Padrino's test helpers" do
  context "for metaprogramming" do
    context "#inline_module" do
      it "should create empty module when no block given" do
        inline_module.should be_kind_of Module
      end
      
      it "should create module with evaluated given block" do
        inline_class { 
          def some_test_method; "Fooobar!"; end 
        }.public_methods.should include "some_test_method"
      end
    end

    context "#inline_klass" do
      it "should create empty class when no block given" do
        inline_class.should be_kind_of Class
      end
      
      it "should create class with evaluated given block" do
        inline_class { 
          def some_test_method; "Fooobar!"; end 
        }.public_methods.should include "some_test_method"
      end
    end
  end
  
  context "for IO" do
    it "#capture_output should be able to capture data from stderr and stdout" do
      out, err = capture_output do
        $stdout.puts "Hello..."
        $stderr.puts "World!"
      end
      out.chomp.should == "Hello..."
      err.chomp.should == "World!"
    end
    
    it "#silence_warnings should decreate verbosity" do
      silence_warnings { $VERBOSE.should be_nil }
    end
    
    it "#fake_stdin should be able to simulate standard input" do
      fake_stdin("Hello...", "World!") do
        gets.chomp.should == "Hello..."
        gets.chomp.should == "World!"
      end
    end
  end
  
end
