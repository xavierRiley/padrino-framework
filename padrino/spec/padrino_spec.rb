require File.expand_path('../spec_helper', __FILE__)

describe "Padrino" do
  it "is a metapackage that requires components" do
    Object.should_not be_const_defined "Padrino"
    require 'padrino'
    Object.should be_const_defined "Padrino"
  end
  
  it "automatically loads additional components" do
    lambda {
      Padrino::Mailer
      Padrino::Helpers
      Padrino::Cache
      Padrino::Admin
    }.should_not raise_error NameError
  end
end
