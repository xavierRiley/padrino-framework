require "padrino"
require File.dirname(__FILE__)+"../app/app.rb"

Padrino.mount('app', :app_class => 'App').to('/')
Padrino.load!
