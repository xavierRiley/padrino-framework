require 'padrino'

class App < Padrino::Application
  get "/hello"
    "Hello World!"
  end
end
