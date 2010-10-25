require File.expand_path('../spec_helper', __FILE__)

describe Padrino do
  context "#view_paths" do
    it "returns list of view paths from all mounted apps" do
      pending
    end
  end
  
  context "#view_files" do
    it "returns list of templates found in view paths from all apps" do
      pending
    end
  end
end

describe Padrino::Rendering do
  subject do
    Sinatra::Base.new do |base| 
      base.class.set :views, Pathname.new("/home/project/firstapp/views")
      base.class.register Padrino::Rendering
      @mock_app = base 
    end unless @mock_app
    @mock_app
  end

  before do 
    Padrino.reset!
    Padrino.instance_variable_set("@view_files", {
      "/home/project/firstapp/views" => %w(
        foo/first.erb
        foo/second.html.erb
        foo/second.xml.erb
        foo/second.pl.html.erb
        foo/third.html.haml
        foo/third.html.erb
        foo/fourth.erb
        foo/fourth.pl.erb
        layouts/application.html.haml
        layouts/test.html.haml
        layouts/foo.erb
        application.html.haml
        test.html.haml
      ),
      "/home/project/secondapp/views" => %w(
        spam/eggs.html.haml
        spam/eggs.erb
      )
    })
  end

  describe "#resolve_layout" do
    context "when :root_layouts option is disabled" do
      before do
        subject.class.disable :root_layouts
      end
      
      it "seeks for `layouts/application.*` by default" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, nil).should == :"layouts/application.html.haml"
      end
      
      it "seeks for given layout in `layouts/` dir" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, 'test').should == :"layouts/test.html.haml"
      end
      
      it "returns false when layout can't be find" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, 'foobar').should == false
      end
      
      it "returns false when layout file has not format specified" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, 'foo').should == false
      end
    end
    
    context "when :root_layouts option is enabled" do
      before do
        subject.class.enable :root_layouts
      end
      
      it "seeks for `application.*` by default" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, nil).should == :"application.html.haml"
      end
      
      it "seeks for given layout in views root dir" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_layout, 'test').should == :"test.html.haml"
      end
    end
  end

  describe "#resolve_template" do
    context "when no locale specified" do
      context "when template has no format specified" do
        it "resolves it if request content type is :html" do
          subject.instance_variable_set("@_content_type", :html)
          subject.send(:resolve_template, "foo/first").should == [:"foo/first.erb", :erb]
        end

        it "resolves it if request content type is :plain" do
          subject.instance_variable_set("@_content_type", :plain)
          subject.send(:resolve_template, "foo/first").should == [:"foo/first.erb", :erb]
        end

        it "raises error if request content type is different than :html and :plain" do
          subject.instance_variable_set("@_content_type", :js)
          expect { subject.send(:resolve_template, "foo/first") }.to raise_error Padrino::Rendering::TemplateNotFound
        end
        
      end
      
      context "when template has format specified" do
        it "resolves it properly" do
          subject.instance_variable_set("@_content_type", :html)
          subject.send(:resolve_template, "foo/second").should == [:"foo/second.html.erb", :erb]
          subject.instance_variable_set("@_content_type", :xml)
          subject.send(:resolve_template, "foo/second").should == [:"foo/second.xml.erb", :erb]
        end
      end
    end
    
    context "when trying to resolve template from another app" do
      it "resolves it properly" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_template, "spam/eggs").should == [:"../../secondapp/views/spam/eggs.html.haml", :haml]
        subject.instance_variable_set("@_content_type", :plain)
        subject.send(:resolve_template, "spam/eggs").should == [:"../../secondapp/views/spam/eggs.erb", :erb]
      end
    end
    
    context "when :engine option specified" do
      it "properly resolves existing template" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_template, "foo/third", :engine => :erb).should == [:"foo/third.html.erb", :erb]
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_template, "foo/third", :engine => :haml).should == [:"foo/third.html.haml", :haml]
      end
      
      it "raises error even when there are templates in other formats" do
        subject.instance_variable_set("@_content_type", :html)
        expect { subject.send(:resolve_template, "foo/third", :engine => :less) }.to raise_error Padrino::Rendering::TemplateNotFound
      end
    end
    
    context "when explicit template format specified" do
      it "properly resolves existing template" do
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_template, "foo/third.erb").should == [:"foo/third.html.erb", :erb]
        subject.instance_variable_set("@_content_type", :html)
        subject.send(:resolve_template, "foo/third.haml").should == [:"foo/third.html.haml", :haml]
      end
      
      it "raises error even when there are templates in other formats" do
        subject.instance_variable_set("@_content_type", :html)
        expect { subject.send(:resolve_template, "foo/third.less") }.to raise_error Padrino::Rendering::TemplateNotFound
      end
    end
    
    context "when locale specified" do
      before do
        subject.class.class_eval { def locale; 'pl'; end } unless subject.respond_to?(:locale)
      end
      
      context "when template has no locale and format specified" do
        it "resolves it" do
          subject.instance_variable_set("@_content_type", :html)
          subject.send(:resolve_template, "foo/first").should == [:"foo/first.erb", :erb]
        end
      end
      
      context "when template has no locale but format specified" do
        it "resolves it if request content type is :html or :plain" do
          subject.instance_variable_set("@_content_type", :xml)
          subject.send(:resolve_template, "foo/second").should == [:"foo/second.xml.erb", :erb]
        end
      end
      
      context "when template has locale but no format specified" do
        it "resolves it properly" do
          subject.instance_variable_set("@_content_type", :html)
          subject.send(:resolve_template, "foo/fourth").should == [:"foo/fourth.pl.erb", :erb]
        end
        
        it "raises error if request content type is different than :html and :plain" do
          subject.instance_variable_set("@_content_type", :js)
          expect { subject.send(:resolve_template, "foo/fourth") }.to raise_error Padrino::Rendering::TemplateNotFound
        end
      end
      
      context "when template has locale and format specified" do
        it "resolves it properly" do
          subject.instance_variable_set("@_content_type", :html)
          subject.send(:resolve_template, "foo/second").should == [:"foo/second.pl.html.erb", :erb]
        end
      end
    end
  end
end
