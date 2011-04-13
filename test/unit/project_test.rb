require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123') 
  end
  
  test "project name must not be empty" do 
    project = Project.new
    assert project.invalid? 
    assert project.errors[:name].any?
  end
  
  test "project must belong to a user" do
    project = Project.new(:name => 'My Project')
    assert project.invalid?
    assert project.errors[:user_id].any?
  end
  
  test "project name must be unique" do
    project1 = Project.new(:name => 'My Project', :user => @user)
    assert project1.save
    
    project2 = Project.new(:name => 'My Project', :user => @user)
    assert project2.invalid?
    assert project2.errors[:name].any?
  end
  
  test "project has tasks" do 
    project = Project.new(:name => 'My Project', :user => @user)
    assert_equal project.tasks.class, Array
  end
  
  test "project has completed and active tasks" do
    @project = Project.create(:name => 'My Project', :user => @user)

    # lets create somewhere between 5 and 15 tasks
    number_of_tasks = 5 + rand(10)
    number_of_tasks.times do |i|
      @project.tasks.create(:description => "task #{i}")
    end
    
    assert @project.tasks.count == number_of_tasks
    
    # lets set at least one of those tasks to be completed
    number_of_completed_tasks = number_of_tasks - rand(number_of_tasks) + 1
    number_of_completed_tasks.times do 
      @project.reload.tasks.where(:completed => false).sample.update_attribute(:completed,true)
    end
    
    assert @project.tasks.completed.count == number_of_completed_tasks
    assert_equal @project.tasks.active.count, (number_of_tasks - number_of_completed_tasks)
  end
  
  test "deleting a project should delete associated tasks" do
    @project = Project.create(:name => 'My Project', :user => @user)
    
    assert @project.tasks.count == 0
    
    5.times do |i|
      @project.tasks.create(:description => "task #{i}")
    end
    
    assert @project.tasks.count == 5
    
    @project.destroy
    
    tasks = Task.where(:project_id => @project.id)
    assert tasks.count == 0
  end
end
