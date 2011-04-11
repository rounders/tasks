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
  
  test "should get new project form" do 
    sign_in @user
    get :new
    assert_response :success
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
    assert_redirected_to assigns(:project)
  end
  
  test "should display errors when trying to create a duplicate project" do
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
  

end
