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
      @tw.some(dom: {project: project}).sort_by(&:urgency).reverse
    else
      @tw.all.sort_by(&:urgency).reverse
    end
  end

 def display_attributes
    [
      :description,
      :project,
      :price,
      :status,
      :due,
      :priority,
      :end,
      :modified
    ]
  end

  post '/tasks/done/:id' do
    id = params[:id]
    project = params[:project]
    @tw.done!(ids: id)
    path = (project == 'nil' || project == nil || project == '') ? '/' : '/tasks?project=' + project
    redirect path, 302
  end

  post '/status' do
    id = params[:id]
    status = params[:status]
    @tw.modify!('status', 'completed', ids: id)
  end

  post '/retask' do
    id = params[:id]
    system("task #{id} modify status:pending")
    redirect '/done', 302
  end

  get '/done' do
    @title = 'Completed Tasks'
    @tasks = @tw.some(dom: {status: 'completed' }, active: false).sort_by(&:end).reverse
    @header = 'Listing'
    @priorities = priority_key
    content = partial :index
    haml :section, locals: { content: content}
  end

  get '/tasks/new' do
    @action = '/tasks/create'
    @shopping_items = format_shopping_items
    @projects = format_for_view(projects)
    @project = params[:project]
    @priorities = priority_key
    @priority = 'L'
    @description = ''
    @price =  nil
    @header = 'New Task'
    @submit = 'Create Task'
    content = partial :form
    haml :section, locals: { content: content }
  end

  get '/test/' do
    content_type :json
    format_shopping_items
  end

  def format_shopping_items
    tasks = @tw.some(dom: { project:'Shopping' }, active: false)

   tasks.map do |task|
                {title: task.description, price: task.price, project: task.project}
   end.to_json
  end

  get '/tasks/edit/:id' do
    id = params[:id]
    task = @tw.some(ids: id).first
    @action = "/tasks/update/#{id}"
    @projects = format_for_view(projects)
    @project = task.project
    @priorities = priority_key
    @priority = task.priority
    @price = task.price
    @description = task.description
    @header = 'New Task'
    @submit = 'Update Task'
    content = partial :form
    haml :section, locals: { content: content }
  end

  post '/tasks/update/:id' do
    id = params[:id]
    description = "'#{params[:description]}'"
    due = params[:due_date] || nil
    priority = params[:priority] || 'L'
    project = "'#{params[:project]}'" || nil
    project = nil if project == "'Unassigned'"
    price = params[:price]

    [:description, :due, :priority, :project, :price].each do  |attr|
      @tw.modify!(attr, eval(attr.to_s), ids: id)
    end

    redirect '/tasks', 302
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
    project = "'#{params[:project]}'" || nil
    project = nil if project == "'Unassigned'"
    price = params[:price]
    @tw.add!(description, dom: {due: due_date, project: project, priority: priority, price: price})
    redirect '/', 302
  end

  get '/projects' do
    @items = format_for_view projects
    @title = 'Projects'
    @header = 'Listing'
    content = partial :list
    haml :section, locals: { content: content  }
  end

  post '/tasks/remove/:id' do
    id = params[:id]
    @tw.delete!(ids: id)
    redirect '/tasks', 302
  end

  get '/tasks/:id' do
    id = params[:id]
    @model = @tw.some(ids: id).first
    @display_attributes = display_attributes
    @header = 'Task Information'

    content = partial 'tasks/show'
    haml :section, locals: { content: content }
  end

  def load_task_warrior
    @tw = Rtasklib::TW.new('~/.task')
  end

  def projects
    @tw.all(active: false).map(&:project).uniq
  end

  def priority_key
    {'H' => 'High',
     'M' => 'Medium',
     'L' => 'Low'}
  end

  def shopping_tasks
    @tw.some(dom: { project: 'Shopping' }, active: false)
  end
end
