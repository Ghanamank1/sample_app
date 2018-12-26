require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  test "should get new" do
    get login_path
    assert_response :success
  end

  test "layout " do
    get login_path 
    post login_path, params: {
                              session: {
                                email: @user.email,
                                password: 'password'
                              }
                            }
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

end