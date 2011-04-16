class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @projects = current_user.projects.all
  end
  
  def show
    @project = current_user.projects.find(params[:id])
    if params[:sort_tasks]
      render :action => 'sort_tasks'
    end
  end
  
  def new
    @project = current_user.projects.new
  end
  
  def create
    @project = current_user.projects.new(params[:project])
    if @project.save
      redirect_to @project
    else
      render :action => 'new'
    end
  end
  
  def edit
    @project = current_user.projects.find(params[:id])
  end
  
  def update
    @project = current_user.projects.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to @project
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @project = current_user.projects.find(params[:id])
    if @project.destroy
      flash[:notice] = "Project #{@project.name} has been sent to the garbage can."
    end
    redirect_to projects_path
  end
  
end