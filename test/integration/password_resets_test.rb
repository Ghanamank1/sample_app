require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:archer)
  end

  test "Password resets" do
    # retrieving the forgot password page 
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Submitting invalid email
    # Checks for the error message
    # Checks to see if the page new path reloads
    post password_resets_path, params: {password_reset: {email:""}}
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Submits a valid email 
    # checks if 1 email for the reset it sent
    # checks to see if the struction popup shows
    # checks if it redirects to the home page for the popup
    post password_resets_path, 
         params: {password_reset: { email: @user.email }}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form 
    # take she @user variable and assigns it to user 
    # i think they did this, so its easier to write the rest
    # of the tests, without putting the '@' everytime
    user = assigns(:user)

    # wrong email 
    # goes to the wrong link from the email and sent to root
    # by putting in the wrong email parameter
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # Inactive user 
    # if user is made not activated, it send the user also 
    # to the root url because it doesn't pass the test. 
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Right email, wrong token
    # putting wrong token in link should send user to root
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # Right email, right token 
    # checks if it goes to the edit page finally from the link
    # then checks if the hidden email element is there
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
 
    # Invalid password and confirmation
    # sends the update to the right user through the token id
    # to see if the validations catch the incorrect entries
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: {
                      password:       "foobaz",
                      password_confirmation: 'bar'
                    }} 
    #assert user.errors.empty?
    #assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'

    # Empty password
    # checks if empty password is caught by the controller
    # check
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: {
                      password: '',
                      password_confirmation: ''
                    }}
    assert_select 'div#error_explanation'

    # Valid password and confirmation
    # this checks if the user gets logged in when they
    # successfully reset then gets the success message
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: {
                      password:        "foobaz",
                      password_confirmation: 'foobaz'
                    }}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to(user_path(user)) 
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match /[expired]/i, response.body
  end
end
