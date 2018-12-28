require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    # the deliveries array is global
    # so there may be other emails in here, if other
    # tests send emails
    # so to prevent the test from failing
    # since it counts for 1 email being sent, we clear the
    # array 
    ActionMailer::Base.deliveries.clear 
  end 

  test "invalid signup information" do
    # gets the page, but its not neccessary for a post request
    get signup_path

    # cheks that after post request, that no user is added
    assert_no_difference 'User.count' do
      post users_path, params: { user: {
                                  name: "",
                                  email: "user@invalid",
                                  password: 'foo',
                                  password_confirmation: 'bar'
                                  }
                                }
    end

    # checks if it goes to new template after the fail
    assert_template 'users/new', "Site is suppose to render the new view after signup failure"
    
    # checking if there are errors
    assert_select 'div#error_explanation'
    assert_select 'div.alert', 'The form contains 4 errors'
  end

  test "valid signup information with account activation" do
    get signup_path

    assert_difference 'User.count', 1 do
      post users_path, params: { user: {
                                  name: "Example User",
                                  email: "example@example.com",
                                  password: "password",
                                  password_confirmation: "password"
                                  }
                                }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # seems to assign to user the user we just created with
    # the post request on signup above
    # grabs the @user instance variable in the create action
    user = assigns(:user)
    # when signing up user is not activated by default
    assert_not user.activated?

    # Try log in before activation.
    # should fail 
    log_in_as(user)
    assert_not is_logged_in?

    # Invalid activation token
    # tries to activate the account with invalid token
    # and doesn't work
    get edit_account_activation_path("Invalid token", email: user.email)
    assert_not is_logged_in?

    # Valid token, wrong email 
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?

    # valid activation token and email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated? 
    follow_redirect!

    # Doesn't redirect to the profile page anymore
    # if the user is not activated 

    assert_template 'users/show'
    assert is_logged_in?, "User is suppose to be logged in"
    
    assert_not flash.empty?
  end
end
