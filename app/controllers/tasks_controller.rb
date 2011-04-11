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
      @task.update_attribute(:position_position,  :last)
      respond_to do |format|
        format.html {redirect_to @project, :notice => 'task successfully created'}
        format.js
      end
    else
      render :action => 'new'
    end
  end
  
 
  
  def destroy
    @task = @project.tasks.find(params[:id])
    if @task.destroy
      flash.now[:notice] = "Task successfully removed"
      respond_to do |format|
        format.html {  redirect_to project_path(@project) }
        format.js
      end
    else
      flash[:notice] = "Could not remove the task for some strange reason"
      respond_to do |format|
        format.html {  redirect_to project_path(@project) }
        format.js { render :status => 500 }
      end
      
    end
    
    
    
   
  end
  
  def toggle_task
    @task = Task.find(params[:id])
    @project = @task.project
    @task.toggle!(:completed)
    # if we are adding to the completed list then always put the item as the first item on that
    # list
    
    # if we are adding to the active list we always add to the bottom
  end
  
  private
  
  def find_project
    @project = Project.find(params[:project_id])
  end
  
  
end
