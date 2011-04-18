require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest

  def setup 
    @user = User.create(:email => 'user@user.com', :password => 'abc123', :password_confirmation => 'abc123')  
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
  end
  
  
end


