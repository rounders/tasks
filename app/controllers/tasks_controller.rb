class TasksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_project, :except => :toggle_completed
  
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
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :status => 500 }
      end
    end
  end

  #  this update action is used only via ajax when sorting tasks
  def update
    @task = @project.tasks.find(params[:id])
    if @task.update_attributes(params[:task])
      flash.now[:notice] = 'task successfully updated'
      render :nothing => true
    else
      format.js { render :status => 500 }
    end
  end
 
  def toggle_completed
    @task = Task.find(params[:id])
    @project = @task.project
    
    if @project.user != current_user
      raise ActiveRecord::RecordNotFound
    else
      @task.toggle!(:completed)
    end
  end
  
  private
  
  def find_project
    @project = current_user.projects.find(params[:project_id])
  end
  
  
end
