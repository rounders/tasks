require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123') 
    @project = Project.create(:name => 'My Project', :user => @user)
    
    # create 5 -  10 sample tasks
    @number_of_tasks = 5 + rand(5)
    @number_of_tasks.times do |i|
      @project.tasks.create(:description => "Task #{i}")
    end
  end
  
  test "task belongs to a project" do
    task = Task.new(:description => 'whatever')
    assert task.invalid?
    assert task.errors[:project_id].any?
  end
  
  test "task should not have an empty description" do
    task = Task.new()
    assert task.invalid?
    assert task.errors[:description].any?
  end
  
  test "a new task should appear at the bottom of the active list" do
    @new_project = Project.create(:name => 'A new Project')
    (5 + rand(10)).times do |i|
      task = @project.tasks.create(:description => "task #{i}")
      assert @project.reload.tasks.active.last == task
    end
  end
  
  test "an active task that is set to completed moves to the top of the completed list" do
    task = @project.tasks.create(:description => 'my task')
    assert_equal @project.tasks.active.last, task
    assert !@project.tasks.completed.include?(task)
    task.update_attribute(:completed, true)

    @project.reload
    
    assert_equal @project.tasks.completed.last, task
    assert !@project.tasks.active.include?(task)
  end
end
