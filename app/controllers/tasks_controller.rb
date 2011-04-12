class TasksController < ApplicationController
  before_filter :find_project, :except => :toggle_task
  
  def index
    @tasks = Task.all
  end
  
  def new
    @task = @project.tasks.new
  end
  
  def update
    @task = @project.tasks.find(params[:id])
    if @task.update_attributes(params[:task])
      flash.now[:notice] = 'task successfully updated'
      respond_to do |format|
        format.html 
        format.js  { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html {render :action => 'edit'}
        format.js { render :status => 500 }
      end
    end
  end
  
  def create
    @task = @project.tasks.new(params[:task])
    if @task.save
      respond_to do |format|
        format.html {redirect_to @project, :notice => 'task successfully created'}
        format.js
      end
    else
      render :action => 'new'
    end
  end
  
 
  def toggle_task
    @task = Task.find(params[:id])

    if @task.project.user != current_user
      render :status => 500, :text => 'Not authorized'
    else
      @task.toggle!(:completed)
    end
  end
  
  private
  
  def find_project
    @project = Project.find(params[:project_id])
  end
  
  
end
