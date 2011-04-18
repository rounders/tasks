require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    # create 5 -  10 sample projects
    @number_of_projects = 5 + rand(5)
    @number_of_projects.times do |i|
      @user.projects.create(:name => "Project #{i}")
    end
  end
  
  test "should redirect to sign in page if not logged in" do
    get :index
    assert_redirected_to new_user_session_path
    
    get :new
    assert_redirected_to new_user_session_path
    
    post :create
    assert_redirected_to new_user_session_path
    
    put :update, :id => @user.projects.sample.id, :project => { }
    assert_redirected_to new_user_session_path
  end
  
  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_select '#new_project_link', 'new project'
    assert_select 'h1', 'My Projects'
    
    assert_select 'ul#projects' do
      assert_select 'li', @number_of_projects
    end
  end
  
  test "should show project" do
    sign_in @user
    get :show, :id => @user.projects.sample.id
    
    assert_response :success
    assert assigns(:project)
    assert_template 'show'
    
    assert_select 'h1', assigns(:project).name
    assert_select '#new_task_link'
  end
  
  test "should show task sorting" do
    sign_in @user
    get :show, :id => @user.projects.sample.id, :sort_tasks => 1
    
    assert_response :success
    assert assigns(:project)
    assert_template 'sort_tasks'
    
    assert_select 'ul.sortable'
    assert_select 'a#done-reordering'
  end
  
  test "should get new project form" do 
    sign_in @user
    get :new
    assert_response :success
    assert_template 'new'
    assert_select 'h1', 'New Project'
    assert_select 'form#new_project', 1  do
      assert_select 'input[type=text]#project_name', 1
    end
  end
  
  test "should create new project" do
    sign_in @user
    assert_difference('Project.count') do
      post :create, :project => { :name => 'my test project' }
    end
    
    assert assigns(:project)
    assert_redirected_to project_path(assigns(:project), :show_task_form => true)
  end
  
  test "should display errors when trying to create a duplicate project for a given user" do
    sign_in @user
    project = Project.first
    post :create, :project => { :name => project.name }
    
    assert_response :success
    assert_template "new"
    
    assert_select '#error_explanation' do
      assert_select 'h2', '1 error prohibited this article from being saved:'
      assert_select 'ul li','Name has already been taken'
    end
  end
  
  test "should show edit form when editing project" do
    sign_in @user
    project = Project.first
    get :edit, :id => project.id
    
    assert_response :success
    assert_template :edit
    assert_equal assigns(:project).id, project.id
    
    assert_select 'form.edit_project', 1 do
      assert_select 'input[type=text]#project_name[value=?]',project.name
    end
  end
  
  test "should update project" do
    sign_in @user
    project = @user.projects.sample
    new_project_name = "my renamed project"
    put :update, :id => project.id, :project => {:name => new_project_name }
    
    assert assigns(:project)
    assert_redirected_to project_path(project)
    assert_equal assigns(:project).name, new_project_name 
  end
  
  test "should render edit form when project update fails" do
    sign_in @user
    project = @user.projects.sample
    new_project_name = ''
    
    put :update, :id => project.id, :project => {:name => new_project_name }
    
    assert assigns(:project)
    assert_template :edit
    assert assigns(:project).errors.any?
  end
  
  test "should delete a project" do
    sign_in @user
    project = @user.projects.sample
    
    assert_difference('Project.count', -1 ) do
      delete :destroy, :id => project.id
    end
    
    assert_redirected_to projects_path
    assert_raise ActiveRecord::RecordNotFound do
      Project.find(project.id)
    end
  end
  
  test "should not delete project when not owned by authenticated user" do
    @user2 = User.create(:email => 'user2@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    sign_in @user2
    
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, :id => @user.projects.sample.id
    end
  end
end
