module Padrino
  module Cache
    module Store
      class Abstract
        def get(key)
          raise NotImplementedError, "#{self.class.name}#get is not implemented."
        end
        
        def [](key)
          get(key)
        end

        def set(key, value, opts=nil)
          raise NotImplementedError, "#{self.class.name}#set is not implemented."
        end

        def []=(key, value)
          set(key, value)
        end

        def delete(key)
          raise NotImplementedError, "#{self.class.name}#delete is not implemented."
        end

        def flush
          raise NotImplementedError, "#{self.class.name}#flush is not implemented."
        end
      end
    end # Store
  end # Cache
end # Padrino
