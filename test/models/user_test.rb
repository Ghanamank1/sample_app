require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
            password: 'foobar', password_confirmation: 'foobar')
  end

  test "should be valid" do
    assert @user.valid? 
  end

  test "name and email should be present" do
    @user.name = "        "
    @user.email = "        "
    assert_not @user.valid? 
  end

  test "name should not be too long" do 
    @user.name = "a"*51
    assert_not @user.valid?
  end

  test "email should not be too long" do 
    @user.email = "a"*244 + "@example.com"

    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                        first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid|
      @user.email = valid
      assert @user.valid?, "#{valid.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar.com
                        foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid|
        @user.email = invalid
        assert_not @user.valid?, "#{invalid.inspect} should be invalid"
    end       
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?, "#{duplicate_user.email.inspect} is a second input and should be invalid"
  end

  test "email address should be saved as lower case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = ''*6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a"*5
    assert_not @user.valid?, "#{@user.password} is #{@user.password.length} characters and should be invalid"
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
