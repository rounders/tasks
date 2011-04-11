require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def setup
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123')
    # create 5 -  10 sample projects
    @number_of_projects = 5 + rand(5)
    @number_of_projects.times do |i|
      @user.projects.create(:name => "Project #{i}")
    end
  end
  
  
end
