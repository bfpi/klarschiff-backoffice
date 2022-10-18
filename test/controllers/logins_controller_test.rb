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

  %w[abc01 abc_1].each do |login|
    test "login with username #{login} returns correct user" do
      post logins_url params: { login: { login:, password: 'Bfpi' } }
      assert_redirected_to root_url
      assert_equal login, session[:user_login]
    end
  end
end
