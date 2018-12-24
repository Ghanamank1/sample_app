require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
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

  test "valid signup information" do
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
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
end
