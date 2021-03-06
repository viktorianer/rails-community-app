# frozen_string_literal: true

require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password reset with invalid email" do
    get new_password_reset_path
    assert_template "password_resets/new"
    # Invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template "password_resets/new"
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "password reset with valid email" do
    # Valid email
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.perishable_token, @user.reload.perishable_token
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "password reset form" do
    # Password reset form
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_redirected_to root_path
    user = assigns(:user)
    assert flash[:info] == "Email sent with password reset instructions"
    # Wrong email
    get edit_password_reset_path(user.perishable_token, email: "")
    assert_redirected_to root_path
    # Inactive user
    user.update(active: false)
    get edit_password_reset_path(user.perishable_token, email: user.email)
    assert_redirected_to root_path
    user.update(active: true)
    # Right email, wrong token
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_path
    # Right email, right token
    get edit_password_reset_path(user.perishable_token, email: user.email)
    assert_response :success
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email
  end

  test "password reset confirmation" do
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_redirected_to root_path
    user = assigns(:user)
    # Invalid password & confirmation
    patch password_reset_path(user.perishable_token), params: { email: user.email,
                                                                user: { password: "foobaz56",
                                                                        password_confirmation: "barquux1" } }

    assert_select "div#error_explanation"
    # Empty password
    patch password_reset_path(user.perishable_token), params: { email: user.email,
                                                                user: { password: "",
                                                                        password_confirmation: "" } }

    assert_select "div#error_explanation"
    # Valid password & confirmation
    patch password_reset_path(user.perishable_token), params: { email: user.email,
                                                                user: { password: "foobaz34",
                                                                        password_confirmation: "foobaz34" } }

    assert_redirected_to user
    assert logged_in?
    assert_not flash.empty?
  end

  test "expired reset token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update(updated_at: 2.hours.ago)
    patch password_reset_path(@user.perishable_token),
          params: { email: @user.email,
                    user: { password: "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    assert_redirected_to root_path
    assert_not flash.empty?
    assert flash[:danger] == "Password reset has expired."
  end

  test "invalid reset token after login" do
    # Password reset form
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_redirected_to root_path
    user = assigns(:user)
    # Valid login
    log_in_as(user, remember_me: "1")
    delete logout_path
    assert_not logged_in?
    # Valid password & confirmation
    patch password_reset_path(user.perishable_token), params: { email: user.email,
                                                                user: { password: "foobaz",
                                                                        password_confirmation: "foobaz" } }
    assert_redirected_to root_path
    assert_not logged_in?
    assert_not flash.empty?
    assert flash[:danger] == "Password reset has expired."
  end
end
