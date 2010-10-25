# XXX: We have to run seperate tests on Hudson to check if there is no problems
# with usign Extlib and AS. 

begin
  # ActiveSupport (3.0) is loaded by default...
  
  require 'active_support/core_ext/string/conversions' 
  require 'active_support/core_ext/kernel'
  require 'active_support/core_ext/module'
  require 'active_support/core_ext/class/attribute_accessors'
  require 'active_support/core_ext/hash/keys'
  require 'active_support/core_ext/hash/deep_merge'
  require 'active_support/core_ext/hash/reverse_merge'
  require 'active_support/core_ext/hash/slice'
  require 'active_support/core_ext/object/blank'
  require 'active_support/core_ext/array'
  require 'active_support/core_ext/float/rounding'
  require 'active_support/ordered_hash'
  require 'active_support/inflector'
  require 'active_support/option_merger'
  require 'active_support/hash_with_indifferent_access'

  begin
    require 'active_support/core_ext/symbol'
  rescue LoadError
  end

  Mash       = ActiveSupport::HashWithIndifferentAccess
  Inflector  = ActiveSupport::Inflector
  Dictionary = ActiveSupport::OrderedHash
rescue LoadError
  # ...if ActiveSupport will be not found, then we are using Merb's Extlib. 

  require 'extlib/inflection'
  require 'extlib/mash'
  require 'extlib/string'
  require 'extlib/class'
  require 'extlib/hash'
  require 'extlib/object'
  require 'extlib/blank'

  Inflector = Extlib::Inflection
end

# Extlib doesn't provide #sindleton_class method, so we need add it when
# it's not defined...
unless Object.respond_to?(:singleton_class)
  class Object
    def singleton_class
      class << self; self end
    end
  end
end

# AS 3.0 has been removed it because is now available in Ruby > 1.8.7 
# but we want keep Ruby 1.8.6 support.
unless :proc.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end 
