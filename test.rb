require 'rtasklib'
require 'sinatra'


class App < Sinatra::Base
  configure do
    register Sinatra::Partial
  end

  before { load_task_warrior }

	get '/' do
    redirect '/tasks', 303
	end

  get '/tasks' do
    @tasks  = get_tasks params
    @title = 'Recent Tasks'
    @header = "#{@project} Listing"
    @priorities = priority_key
    content = partial :index
    haml :section, locals: { content: content, new: {name: 'New Task', href: '/tasks/new?project=' + @project.to_s}  }
  end

  def get_tasks(params)
    if @project = params[:project]
      project = if project == 'Unassigned'
                 nil
                else
                  @project
                end
      @tw.some(dom: {project: project})
    else
      @tw.all
    end
  end

  post '/done' do
    id = params[:id]
    project = params[:project]
    @tw.done!(ids: id)
    path = project == 'nil' ? '/' : '/tasks?project=' + project
    redirect path, 302
  end

  post '/status' do
    id = params[:id]
    status = params[:status]
    @tw.modify!('status', 'completed', ids: id)
  end

  get '/done' do
    @title = 'Completed Tasks'
    @tasks = @tw.some(dom: {status: 'completed' }, active: false)
    @header = 'Listing'
    @priorities = priority_key
    content = partial :index
    haml :section, locals: { content: content}
  end

  get '/tasks/new' do
    @projects = format_for_view(projects)
    @project = params[:project]
    @priorities = priority_key
    @header = 'New Task'
    content = partial :form
    haml :section, locals: { content: content }
  end

  def format_for_view(projects)
    index = projects.find_index(nil)
    projects[index] = 'Unassigned'
    projects
  end

  post '/tasks/create' do
    description = params[:description]
    due_date = params[:due_date] || nil
    priority = params[:priority] || 'L'
    project = params[:project] || nil
    project = nil if project == 'Unassigned'
    @tw.add!(description, dom: {due: due_date, project: project, priority: priority})
    redirect '/', 302
  end

  get '/projects' do
    @items = format_for_view projects
    @title = 'Projects'
    @header = 'Listing'
    content = partial :list
    haml :section, locals: { content: content  }
  end

  def load_task_warrior
    @tw = Rtasklib::TW.new('~/.task')
  end

  def projects
    projects = @tw.all(active: false).map(&:project).uniq
  end

  def priority_key
    {'H' => 'High',
     'M' => 'Medium',
     'L' => 'Low'}
  end
end
