ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  #  include the Devise Test Helpers in all of our tests
  class ActionController::TestCase
    include Devise::TestHelpers
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  self.use_transactional_fixtures = false
  def sign_in(email,password)
    visit '/'
    page.fill_in 'user_email', :with => email
    page.fill_in 'user_password', :with => password
    page.click_button('Sign in')

  end
end