module Padrino
  module Testing
    module Meta
      ##
      # Quickly create inline class with given block evaluated.
      #
      # ==== Examples
      #
      #   inline_class do 
      #     include Foo
      #     def hello
      #       puts "Hello world!"
      #     end
      #   end 
      #
      def inline_class(base=Object, &block)
        klass = Class.new(base)
        klass.instance_eval(&block) if block_given?
        klass
      end
      
      ##
      # Quickly create inline module with given block evaluated.
      #
      # ==== Examples
      #
      #   inline_module do
      #     def hello
      #       puts "Hello world!"
      #     end
      #   end 
      #
      def inline_module(&block)
        mod = Module.new
        mod.instance_eval(&block) if block_given?
        mod
      end
      
    end # Meta
  end # Testing
end # Padrino
