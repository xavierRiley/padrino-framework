$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'riot'
require 'mocha'
require 'mocha/api'
require 'padrino-core'

# Dot-matrix reporter
Riot.dots

# Test helpers
Riot::Situation.send :include, Mocha::API
