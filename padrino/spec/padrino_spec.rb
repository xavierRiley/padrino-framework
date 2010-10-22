require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Padrino" do
  it "should be a metagem that requires components" do
    Object.should_not be_const_defined "Padrino"
    require 'padrino'
    Object.should be_const_defined "Padrino"
  end
  
  it "should be able to autoload additional components" do
    lambda {
      Padrino::Mailer
      Padrino::Helpers
      Padrino::Cache
      Padrino::Admin
    }.should_not raise_error NameError
  end
end
