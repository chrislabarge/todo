require 'rtasklib'
require 'sinatra'

#tw = Rtasklib::TW.new('/usr/local/bin/task')

#puts tw.methods.sort

class App < Sinatra::Base
  configure do
    register Sinatra::Partial
  end

	get '/yo' do
    @header = 'Task Helper'
    content = partial :index
    haml :section, locals: { content: content, title: 'Some title'  }
	end
end
