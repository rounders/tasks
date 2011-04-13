require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    @project = @user.projects.create(:name => "My Project")

    # create 5 -  10 sample tasks
    @number_of_tasks = 5 + rand(5)
    @number_of_tasks.times do |i|
      @project.tasks.create(:description => "Task #{i}")
    end
  end
  
  test "should redirect to sign in page if not logged in" do
    get :new, :project_id => @project
    assert_redirected_to new_user_session_path
    
    post :create, :project_id => @project, :task => { :description => 'my test project' }
    assert_redirected_to new_user_session_path
  end
  
  test "should display new task form" do 
    sign_in @user
    get :new, :project_id => @project
    assert_response :success
    assert_select 'form#new_task'
  end
  
  test "should create new task" do
    sign_in @user
    assert_difference('Task.count') do
      post :create, :project_id => @project, :task => { :description => 'my test project' }
    end
    
    assert assigns(:project)
    assert assigns(:task)
    assert_equal assigns(:task).description, 'my test project'
    assert_redirected_to project_path(assigns(:project))
  end
  
  test "should update an existing task" do
    sign_in @user
    task = @project.tasks.sample
  end
  

end
