require 'padrino'

class RackupConfigApp < Padrino::Application
  get "/hello" do
    "Hello world!"
  end
end

Padrino.mount('rackup_config_app', :app_class => 'RackupConfigApp').to('/')
Padrino.load!
