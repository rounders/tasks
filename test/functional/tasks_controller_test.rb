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
    
    put :toggle_completed, :id => @project.tasks.sample.id, :format => 'js'
    assert_response :unauthorized
    
    put :toggle_completed, :id => @project.tasks.sample.id, :format => 'html'
    assert_redirected_to new_user_session_path
  end
  
  # test GET /new
  test "should display new task form" do 
    sign_in @user
    get :new, :project_id => @project
    assert_response :success
    assert_select 'form#new_task'
  end

  # 
  test "should create new task (html)" do
    sign_in @user
    assert_difference('Task.count') do
      post :create, :project_id => @project, :task => { :description => 'my test project' }
    end
    
    assert assigns(:project)
    assert assigns(:task)
    assert_equal assigns(:task).description, 'my test project'
    assert_redirected_to project_path(assigns(:project))
  end
  
  test "should create new task (js)" do
    sign_in @user
    assert_difference('Task.count') do
      post :create, :project_id => @project, :task => { :description => 'my test project' }, :format => 'js'
    end
    
    assert assigns(:project)
    assert assigns(:task)
    assert_equal assigns(:task).description, 'my test project'
    assert_template "create"
  end
  
  test "should not create a blank task" do
    sign_in @user
    post :create, :project_id => @project, :task => { :description => '' }
    
    assert_response :success
    assert_template 'new'
    assert assigns(:project)
    assert assigns(:task)
    
    post :create, :project_id => @project, :task => { :description => '' }, :format => 'js'
    assert_response :unprocessable_entity
  end
  
  test "should update an existing task" do
    sign_in @user
    task = @project.tasks.sample
    put :update, :format => 'js', :project_id => @project, :id => task.id, :task => { :description => 'blah blah'}
    
    assert_response :success
    assert assigns(:project)
    assert assigns(:task)
    assert_equal assigns(:task).description, "blah blah"
    assert_equal flash[:notice], "task successfully updated"
  end
  
  test "updating an existing task with invalid data should fail" do
    sign_in @user
    task = @project.tasks.sample
    
    put :update, :format => 'js', :project_id => @project, :id => task.id, :task => { :description => '' }
    assert_response :unprocessable_entity
    
    put :update, :format => 'html', :project_id => @project, :id => task.id, :task => { :description => '' }
    assert_response :unprocessable_entity
  end
  
  test "should not update a task which does not belong to us" do
    sign_in @user

    @user2 = User.create(:email => 'user2@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    @project2 = @user2.projects.create(:name => 'My Project')
    @task = @project2.tasks.create(:description => 'my task')
    task = @project.tasks.sample
    
    # using project_id belonging to @user2
    assert_raise ActiveRecord::RecordNotFound do
      put :update, :format => 'js', :project_id => @project2.id, :id => task.id, :task => {:description => 'blah blah'}
    end
    
    # using project_id belonging to @user but task id belonging to @user2
    assert_raise ActiveRecord::RecordNotFound do
      put :update, :format => 'js', :project_id => @project.id, :id => @task.id, :task => {:description => 'blah blah'}
    end
  end
  
  # test toggle_complete method with an authenticated user
  test "should toggle completed attribute for a task belonging to authenticated user" do
    sign_in @user
    
    task = @project.tasks.sample
    
    put :toggle_completed, :id => task.id, :format => 'js'
    assert_response :success
    assert assigns(:task)
    assert_equal task.completed, !assigns(:task).completed
  end
  
  # test toggle_complete method with an authenticated user who does not own the task
  test "should not toggle completed attribute for a task not belonging to the authenticated user" do
    @user2 = User.create(:email => 'user2@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    sign_in @user2
    
    # a task that does not belong to @user2
    task = @project.tasks.sample
    
    assert_raise ActiveRecord::RecordNotFound do
      put :toggle_completed, :id => task.id, :format => 'js'
    end
  end

end
