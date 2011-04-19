require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest

  def setup 
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123')

    # generate 5 - 10 projects
    @number_of_projects = 5 + rand(5)
    @number_of_projects.times do |i|
      @user.projects.create(:name => "Project #{i}")
    end
    
    # pick one of the projects at random
    @project = @user.projects.sample

    # generate 5 - 10 tasks for @project
    @number_of_tasks = 5 + rand(5)
    @number_of_tasks.times do |i|
      @project.tasks.create(:description => "Task #{i}")
    end  
  end

  # Replace this with your real tests.
  test "a user should be able to sign in" do
    visit '/'
    assert page.has_selector?('h2', :text => 'Sign in')
    page.fill_in 'user_email', :with => 'user@user.com'
    page.fill_in 'user_password', :with => 'abc123'
    page.click_button('Sign in')
    assert page.has_selector?('.notice', :text => 'Signed in successfully')
  end
  
  test "a signed in user should see a list of his projects" do
    sign_in('user@user.com','abc123')
    assert page.has_selector?('h1', :text => 'My Projects')
    assert page.has_selector?('ul#projects li', :count => @user.projects.count)
  end
  
  test "adding a project" do 
    sign_in('user@user.com','abc123')

    page.click_link('new_project_link')
    assert_equal current_path, new_project_path
    page.fill_in 'project_name', :with => 'My New Project'
    page.click_button('Create Project')
    

    # we should now be on the show page for the newly created project
    assert page.has_selector?('h1', :text => 'My New Project')

    # lets return to the projects page
    page.click_link('all projects')
    assert_equal current_path, projects_path
    assert page.has_selector?('ul#projects li:last-child a', :text => 'My New Project')
    assert page.has_selector?('ul#projects li', :count => @user.projects.count)
  end
  
  test "a user should see a list of tasks associated with a given project" do
    sign_in('user@user.com', 'abc123')
    page.click_link(@project.name)
    assert_equal current_path, project_path(@project)
    assert page.has_selector?('ul#active-tasks-list li', :count => @project.tasks.count)
    @project.tasks.each do |task|
      assert page.has_selector?('ul#active-tasks-list li span', :text => /#{task.description}/)
    end
  end
  
  test "adding a task to a project" do
  end
  
  
end


