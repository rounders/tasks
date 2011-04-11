require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123') 
    @project = Project.create(:name => 'My Project', :user => @user)
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
end
