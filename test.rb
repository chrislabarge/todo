require 'rtasklib'
require 'sinatra'

tw = Rtasklib::TW.new('/usr/local/bin/task')

puts tw.methods.sort

class App < Sinatra::Base
	get '/yo' do 
	'hellow thereeeeee'
	end
end
