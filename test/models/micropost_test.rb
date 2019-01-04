require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
 
  def setup
    @user = users(:michael)

    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?, "User id must be present"
  end

  test "Micropost must not exceed max length" do
    @micropost.content = "a"*141
    assert_not @micropost.valid?, "Micropost must be less than 140"
  end

  test "micropost must be present" do
    @micropost.content = "     "
    assert_not @micropost.valid?, "Micropost must be present"
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
