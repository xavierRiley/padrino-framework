module Padrino
  ##
  # Manages current Padrino version for use in gem generation.
  #
  # We put this in a separate file so you can get padrino version
  # without include full padrino core.
  #
  module Version
    unless defined?(Padrino::VERSION)
      MAJOR  = 1
      MINOR  = 0
      PATCH   = 0
      STRING = [MAJOR, MINOR, PATCH].join('.')
    end
  end
  
  ##
  # Return the current Padrino version
  #
  def self.version
    Version::STRING
  end
end # Padrino
