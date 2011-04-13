class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project, :except => :toggle_task
  
  def new
    @task = @project.tasks.new
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
    @project = @task.project
    
    if @project.user != current_user
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
