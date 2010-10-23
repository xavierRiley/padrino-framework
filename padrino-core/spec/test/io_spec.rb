require File.join(File.dirname(__FILE__), 'spec_helper')

describe Padrino::Test::IO do
  describe "#capture_output" do
    it "captures data from stdout" do
      out, err = capture_output { $stdout.puts "Hello..." }
      out.chomp.should == "Hello..."
    end
    
    it "captures data from stderr" do
      out, err = capture_output { $stderr.puts "Hello..." }
      err.chomp.should == "Hello..."
    end
  end
  
  describe "#silence_warnings" do
    it "decreases verbosity" do
      verbose = true
      silence_warnings { verbose = $VERBOSE }
      verbose.should be_nil
    end
  end
  
  describe "#fake_stdin" do
    it "simulates standard input" do
      res = [] and 
      fake_stdin("Hello...", "World!") do
        res << $stdin.gets.chomp
        res << $stdin.gets.chomp
      end
      res.should == ["Hello...", "World!"]
    end
  end
end
