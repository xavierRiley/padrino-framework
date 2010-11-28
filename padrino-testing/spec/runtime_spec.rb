require File.expand_path('../spec_helper', __FILE__)

describe Padrino::Testing::Runtime do
  describe "#without_argv" do
    it "executes given block with empty ARGV" do
      argv = []
      without_argv { argv = ARGV }
      argv.should be_empty
    end
  end
end
