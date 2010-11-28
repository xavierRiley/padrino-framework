module Padrino
  module Testing

    autoload :Meta,    "padrino-testing/meta"
    autoload :IO,      "padrino-testing/io"
    autoload :Files,   "padrino-testing/files"
    autoload :Rack,    "padrino-testing/rack"
    autoload :Runtime, "padrino-testing/runtime"

    ##
    # Include all testing helpers at one time, simple including
    # <tt>Padrino::Testing</tt> module. 
    #
    def self.included(base) # :nodoc:
      base.send :include, Padrino::Testing::Meta
      base.send :include, Padrino::Testing::IO
      base.send :include, Padrino::Testing::Files
      base.send :include, Padrino::Testing::Rack
      base.send :include, Padrino::Testing::Runtime
    end

  end # Testing
end # Padrino
