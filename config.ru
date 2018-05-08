require 'sinatra'
require 'haml'
require 'sinatra/partial'
require 'sass/plugin/rack'
#require "sprockets"
#require "sprockets-sass"
#require "sprockets-helpers"
#require 'semantic-ui-sass'
require './test.rb'
#run Sinatra::Application
Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run App
