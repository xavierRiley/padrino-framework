require File.expand_path('../../spec_helper', __FILE__)

describe Padrino::Test::Files do
  describe "#path" do
    it "returns expanded path to given file" do
      path_to(__FILE__, "fixtures/apps").should == File.expand_path('fixtures/apps', File.dirname(__FILE__))
    end
  end
  
  context "#with_view" do
    before :each do
      @fname = path_to(__FILE__, "views/test.html")
      @result  = nil
    end
    
    it "creates given directory" do
      fname = @fname
      with_view(__FILE__, "test.html", "Test!") {|f| @result = File.read(f) }
      @result.should == "Test!"
    end
  
    it "removes automaticaly created directory after block execution" do
      @fname = path_to(__FILE__, "views")
      within_dir(__FILE__, "test.html", "Test!") { }
      File.should_not be_exists @fname
    end
  end
  
  context "#within_dir" do
    context "when given directory exists" do
      before :each do
        @dirname = path_to(__FILE__, "fixtures")
        @result  = nil
      end
      
      it "executes block in context of given directory" do
        within_dir(__FILE__, "fixtures") {|dir| @result = dir }
        @result.should == @dirname
      end
    end
    
    context "when given directory doesn't exist" do
      before :each do
        @dirname = path_to(__FILE__, "tmp")
        @result  = nil
      end
      
      it "creates given directory" do
        within_dir(__FILE__, "tmp") {|dir| @result = File.directory?(dir) }
        @result.should be_true
      end
    
      it "removes automaticaly created directory after block execution" do
        @dirname = path_to(__FILE__, "tmp/foo/bar")
        within_dir(__FILE__, "tmp/foo/bar") {|dir| @result = dir }
        File.should_not be_exists @result
      end
    end
  end
end
