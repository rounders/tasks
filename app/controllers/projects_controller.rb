class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end
  
  def show
    @project = Project.find(params[:id])
    if params[:sort_tasks]
      render :action => 'sort_tasks'
    end
    
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = Project.new(params[:project])
    if @project.save
      respond_to do |format|
        format.html {redirect_to projects_path, :notice => "Project successfully created"}
        format.js
      end
    else
      render :action => 'new'
    end
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to @project, :notice => "Project successfully updated"
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @project = Project.find(params[:id])
    if @project.destroy
      flash[:notice] = "Project #{@project.name} has been sent to the garbage can."
    else
      flash[:notice] = "I could not delete the thing for some reason"
    end
    redirect_to projects_path
  end
  
  def sort_tasks
    @project = Project.find(params[:id])
    params[:tasks].each_with_index do |task_id,index|
      @project.tasks.find(task_id).update_attribute(:position_position,index)
    end
    render :nothing => true
  end
end