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
      res = []
      fake_stdin("Hello...", "World!") do
        res << $stdin.gets.chomp
        res << $stdin.gets.chomp
      end
      res.should == ["Hello...", "World!"]
    end
  end
  
  context "for Files" do
    it "#path_to should return expanded path to given file" do
      path_to(__FILE__, "fixtures/apps").should == File.expand_path('fixtures/apps', File.dirname(__FILE__))
    end
  
    it "#within_dir should execute block in context of given directory" do
      dirname, res = path_to(__FILE__, "fixtures"), nil
      within_dir(__FILE__, "fixtures") {|dir| res = dir }
      res.should == dirname
    end
    
    it "#within_dir should create given directory if it not exists" do
      dirname, res = path_to(__FILE__, "tmp"), nil
      within_dir(__FILE__, "tmp") do |dir| 
        res = dir 
        File.should be_directory res
      end
      res.should == dirname
    end
    
    it "#within_dir should properly remove automaticaly created directory" do
      dirname, res = path_to(__FILE__, "tmp/foo/bar"), nil
      within_dir(__FILE__, "tmp/foo/bar") {|dir| res = dir }
      res.should == dirname
      File.should_not be_exists res
    end
  end
  
  context "for Rack" do
    it "#set_app should set current rack test application" do
      set_app(test_app = proc {})
      app.should == test_app
    end
    
    it "#within_app should execute given block in rack application context" do
      test_app, res = proc {}, nil
      within_app(test_app) { res = app }
      res.should == test_app
      app.should_not == test_app 
    end
  end
  
  context "for Runtime" do
    it "#with_no_argv should execute given block with empty ARGV" do
      argv = []
      without_argv { argv = $ARGV }
      argv.should == nil
    end
  end
end
