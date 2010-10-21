module Padrino
  module Testing
  
    module Metaprogramming

      def inline_class(&block)
        klass = Class.new(Object)
        klass.instance_eval(&block) if block_given?
        klass
      end
      
      def inline_module(&block)
        mod = Module.new
        mod.instance_eval(&block) if block_given?
        mod
      end
      
    end # Metaprogramming
  end # Testing
end # Padrino
