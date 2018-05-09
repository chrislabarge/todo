require 'rtasklib'
require 'sinatra'


class App < Sinatra::Base
  configure do
    register Sinatra::Partial
  end

	get '/yo' do
    @tw = Rtasklib::TW.new('~/.task')
    @tasks  = @tw.all
    content = partial :index
    haml :section, locals: { content: content, title: 'Listing'  }
	end
end
