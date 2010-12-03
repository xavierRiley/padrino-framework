require File.expand_path('../spec_helper', __FILE__)

shared_examples_for "cache store" do
  after do
    @cache.flush!
  end

  it "should set and get a value" do
    @cache.set('val', 'test')
    @cache.get('val').should == 'test'
  end
  
  describe "#get" do
    it "should return nil trying to get a value that doesn't exist" do
      @cache.get('not_exists').should_not be
    end
  end

  describe "#set" do
    context "when :expires_in option given" do
      it "should set a value that expires" do
        @cache.set('val', 'test', :expires_in => 1)
        @cache.get('val').should == 'test'
        sleep 2
        @cache.get('val').should == nil
      end
    end
  end

  describe "#delete" do
    it "should remove given item" do
      @cache.set('val', 'test')
      @cache.delete('val')
      @cache.get('val').should_not be
    end
  end

  describe "#flush!" do
    it "should remove all items" do
      3.times { |i| @cache.set(i.to_s, i.to_s) }
      @cache.flush!
      3.times { |i| @cache.get(i.to_s).should_not be }
    end
  end
end

describe "Padrino cache" do
  describe "Abstract store" do
    before do 
      @cache = Padrino::Cache::Store::Abstract.new
    end

    it "#set should raise NotImplementedError" do
      expect { @cache.set('val', 'test') }.to raise_error(NotImplementedError)
    end

    it "#get should raise NotImplementedError" do
      expect { @cache.get('val') }.to raise_error(NotImplementedError)
    end

    it "#delete should raise NotImplementedError" do
      expect { @cache.delete('val') }.to raise_error(NotImplementedError)
    end

    it "#flush! should raise NotImplementedError" do
      expect { @cache.flush! }.to raise_error(NotImplementedError)
    end

    context "#[]" do
      it "should be syntactic sugar for get" do
        @cache.expects(:get).with('val').returns('test')
        @cache['val'].should == 'test'
      end
    end

    context "#[]=" do
      it "should be syntactic sugar for set" do
        @cache.expects(:set).with('val', 'test').returns('test')
        (@cache['val'] = 'test').should == 'test'
      end
    end
  end

  describe "Memcache store", :require => 'memcache' do
    before :all do
      @cache = Padrino::Cache::Store::Memcache.new('127.0.0.1:11211', :exception_retry_limit => 1)
    end

    it_should_behave_like "cache store"
  end

  describe "Redis store", :require => 'redis' do
    before :all do
      @cache = Padrino::Cache::Store::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0)
    end

    it_should_behave_like "cache store"
  end

  describe "File store" do
    before :all do
      @tmpdir = make_tmpdir('padrino-tests/cache')
      @cache = Padrino::Cache::Store::File.new(@tmpdir.to_s)
    end

    it_should_behave_like "cache store"
  end

  describe "In memory store" do
    before :all do
      @cache = Padrino::Cache::Store::Memory.new(50)
    end

    it_should_behave_like "cache store"

    it "should only store 50 entries" do
      51.times { |i| @cache.set(i.to_s, i.to_s) }
      @cache.get('0').should_not be
      @cache.get('1').should == '1'
      @cache.get('50').should ==  '50'
    end
  end
end
