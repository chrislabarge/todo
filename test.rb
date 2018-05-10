require 'rtasklib'
require 'sinatra'


class App < Sinatra::Base
  configure do
    register Sinatra::Partial
  end

	get '/' do
    @tw = Rtasklib::TW.new('~/.task')
    @tasks  = @tw.all
    content = partial :index
    haml :section, locals: { content: content, title: 'Listing'  }
	end

  post '/done' do
    @tw = Rtasklib::TW.new('~/.task')
    id = params[:id]
    @tw.done!(ids: id)
  end

  post '/status' do
    @tw = Rtasklib::TW.new('~/.task')
    id = params[:id]
    status = params[:status]
    @tw.modify!('status', 'completed', ids: id)
  end

  get '/done' do
    @tw = Rtasklib::TW.new('~/.task')
    @tasks = @tw.some(dom: {status: 'completed' }, active: false)
    content = partial :index
    haml :section, locals: { content: content, title: 'Listing'  }
  end
end
