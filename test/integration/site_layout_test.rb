require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links when not logged in" do
    get root_path
    # header
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", root_path, text: "Home", count: 1
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", logout_path, count: 0
    # footer
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", help_path
  end

  test "page title when not logged in" do
    # header
    get root_path
    assert_select "title", full_title("")
    get login_path
    assert_select "title", full_title("Log in")
    get signup_path
    assert_select "title", full_title("Sign up")

    # footer
    get about_path
    assert_select "title", full_title("About")
    get contact_path
    assert_select "title", full_title("Contact")
    get help_path
    assert_select "title", full_title("Help")
  end

  test "layout links when logged in" do
    user = users(:michael)
    log_in_as(user)
    get root_path
    # header
    assert_select "a[href=?]", login_path, count: 0
    # no menu administration
    assert_select 'li.dropdown a.dropdown-toggle', count: 1
    assert_select "a[href=?]", users_path, count: 0
    # menu account
    assert_select 'li.dropdown a.dropdown-toggle', 'Account', count: 1
    assert_select "a[href=?]", user_path(user)
    assert_select "a[href=?]", edit_user_path(user)
    assert_select "a[href=?]", logout_path
    # footer
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", help_path
  end

  test "page title when logged in" do
    user = users(:michael)
    log_in_as(user)
    # menu account
    get user_path(user)
    assert_select "title", full_title(user.name)
    get edit_user_path
    assert_select "title", full_title("Edit user")
  end


  test "layout links when logged in as admin" do
    user = users(:lana)
    log_in_as(user)
    get root_path
    # header
    assert_select "a[href=?]", login_path, count: 0
    # menu administration
    assert_select 'li.dropdown a.dropdown-toggle', 'Administration', count: 1
    assert_select "a[href=?]", users_path
  end

  test "page title when logged in as admin" do
    user = users(:lana)
    log_in_as(user)
    # menu administration
    get users_path
    assert_select "title", full_title("All users")
  end
end