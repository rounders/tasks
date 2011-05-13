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
  
  def teardown
    DatabaseCleaner.clean
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
    Capybara.current_driver = :selenium
    
    sign_in('user@user.com', 'abc123')
    page.click_link(@project.name)
    assert !page.find_by_id('task_description').visible?
    page.click_link('add a new task')

    assert page.find_by_id('task_description').visible?
    page.fill_in 'task_description', :with => 'my new task'
    page.click_button('Add this task')
    
    assert page.has_selector?('ul#active-tasks-list li:last-child span', :text => 'my new task')

    page.click_link('close')
    assert !page.find_by_id('new_task_form').visible?
  end
  
  test "completing a task" do
    Capybara.current_driver = :selenium
    
    sign_in('user@user.com', 'abc123')
    page.click_link(@project.name)
    
    random_task = @project.tasks.sample
    assert page.has_selector?('ul#active-tasks-list li span', :text => random_task.description)

    page.check("activetask-#{random_task.id}")
    assert page.has_selector?('div#completed-tasks ul li span', :text => random_task.description)
    
    page.uncheck("completedtask-#{random_task.id}")
    assert page.has_selector?('ul#active-tasks-list li span', :text => random_task.description)
  end
  
  test "reordering tasks" do
    Capybara.current_driver = :selenium

    last_task = @project.tasks.active.last
    assert_not_equal last_task.description, @project.tasks.active.first.description
    
    sign_in('user@user.com','abc123')
    page.click_link(@project.name)
    
    page.click_link('reorder')
    
    # load jquery.simulate and then drag the last task to the first.
    page.execute_script %Q{
      $.getScript("/javascripts/jquery.simulate.js", function(){
      	first_child_y = $('.task:first img').offset().top;
      	last_child_y  = $('.task:last img').offset().top;
      	dy = first_child_y - last_child_y;

      	last = $('.task:last img');
      	last.simulate('drag', {dx:0, dy:dy});
      });
    }      
    
    # verify that visually the sorting has occured   
    assert page.has_selector?('ul#active-tasks-list li:first-child span', :text => last_task.description)
        
    # verify that the sorting has actually occured in the database  
    assert_equal @project.tasks.reload.active.first.description, last_task.description
  end
  
  test "reordering tasks part deux" do
    Capybara.current_driver = :selenium

    first_task = @project.tasks.active.first
    assert_not_equal first_task.description, @project.tasks.active.last.description
    
    sign_in('user@user.com','abc123')
    page.click_link(@project.name)
    
    page.click_link('reorder')
    
    # load jquery.simulate and then drag the first task to the last position.
    page.execute_script %Q{
      $.getScript("/javascripts/jquery.simulate.js", function(){ 
        distance_between_elements = $('.task:nth-child(2) img').offset().top - $('.task:nth-child(1) img').offset().top;
        height_of_elements = $('.task:nth-child(1) img').height();
        dy = (distance_between_elements * ( $('.task').size() - 1 )) + height_of_elements/2;

      	first = $('.task:first img');
      	first.simulate('drag', {dx:0, dy:dy});
      });
    }
    
    # verify that visually the sorting has occured
    assert page.has_selector?('ul#active-tasks-list li:last-child span', :text => first_task.description)
                                                  
    # verify that the sorting has actually occured in the database
    assert_equal @project.tasks.reload.active.last.description, first_task.description
  end
  
  test "editing a project" do
    Capybara.current_driver = :selenium
    
    sign_in('user@user.com','abc123')
    page.click_link(@project.name)
    
    page.click_link('edit')
    assert_equal current_path, edit_project_path(@project)
    assert page.has_selector?('h2', :text => 'Edit')

    page.fill_in 'project_name', :with => 'This is a new name'
    random_task = @project.tasks.sample

    page.find("#task_#{random_task.id} a").click
    page.click_button('Update Project')
    
    assert page.has_selector?('h1', :text => 'This is a new name')
    assert !page.has_selector?('ul#active-tasks-list li span', :text => random_task.description)
    # save_and_open_page
  end
  
  
  
  
end


