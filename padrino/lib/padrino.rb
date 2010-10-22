# Only core is necessary for proper work. Additional components, like mailer
# or admin can be autoloaded later (on first use). 

module Padrino
  autoload :Helpers, "padrino-helpers"
  autoload :Mailer,  "padrino-mailer"
  autoload :Admin,   "padrino-admin"
  autoload :Cache,   "padrino-cache"
end

require 'padrino-core'
