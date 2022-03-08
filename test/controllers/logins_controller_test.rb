# frozen_string_literal: true

require 'test_helper'

class LoginsControllerTest < ActionDispatch::IntegrationTest
  %i[login email].each do |attr|
    test "login with #{attr} and password" do
      user = user(:one)
      post logins_url params: { login: { login: user[attr], password: 'Bfpi' } }
      assert_redirected_to root_url
      assert_equal user.login, session[:user_login]
    end
  end
end
