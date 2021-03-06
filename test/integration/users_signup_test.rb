# frozen_string_literal: true

require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template "users/new"
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.active?
    # Try to log in before activation.
    log_in_as(user)
    assert_not logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.perishable_token, email: "wrong")
    assert_not logged_in?
    # Valid activation token
    get edit_account_activation_path(user.perishable_token, email: user.email)
    assert user.reload.active?
    assert user.reload.approved?
    assert user.reload.confirmed?
    assert_redirected_to user_path(user)
    follow_redirect!
    assert_template "users/show"
    assert logged_in?
    assert_not flash.empty?
    assert flash[:success] == "Account activated!"
  end

  test "expired activation token" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.active?
    user.update(updated_at: 2.hours.ago)
    get edit_account_activation_path(user.perishable_token, email: user.email)
    assert_not user.reload.active?
    assert_not user.reload.approved?
    assert_not user.reload.confirmed?
    assert_response :redirect
    assert_redirected_to root_path
    assert_not flash.empty?
    assert flash[:danger] == "Invalid activation link"
  end

  test "signup form" do
    get signup_path
    assert_template "users/new"
    assert_select "form#new_user"
    assert_select "input#user_name"
    assert_select "input#user_email"
    assert_select "input#user_password"
    assert_select "input#user_password_confirmation"
    assert_select "select#user_locale"
    assert_select "div.g-recaptcha"
    assert_select "label", 6
  end
end
