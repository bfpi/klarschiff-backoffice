# frozen_string_literal: true

require 'test_helper'

class LoginsControllerTest < ActionDispatch::IntegrationTest
  %i[login email].each do |attr|
    test "login with #{attr} and password" do
      user = user(:one)
      post_login user[attr]
      assert_redirected_to root_url
      assert_equal user.login, session[:user_login]
    end
  end

  %w[abc01 abc_1].each do |login|
    test "login with username #{login} returns correct user" do
      User.stub :active, User.active.order(:login) do
        post_login login
        assert_redirected_to root_url
        assert_equal login, session[:user_login]
      end
    end

    test "login with email for user #{login} returns correct user" do
      User.stub :active, User.active.order(:email) do
        post_login user(login).email
        assert_redirected_to root_url
        assert_equal login, session[:user_login]
      end
    end
  end

  test 'login authenticates against d.3 with login and password of user' do
    credentials = nil
    dms_login = lambda do |username, password|
      credentials = [username, password]
      { 'd3' => 'token' }
    end
    post_login(user(:one).email, dms_login:)
    assert_redirected_to root_url
    assert_equal [user(:one).login, 'Bfpi'], credentials
    assert_equal({ 'd3' => 'token' }, session[:dms_session_id])
  end

  test 'login succeeds even if d.3 authentication fails' do
    post_login user(:one).login, dms_login: {}
    assert_redirected_to root_url
    assert_equal user(:one).login, session[:user_login]
    assert_empty session[:dms_session_id]
  end

  test 'logout ends d.3 session on server and removes it' do
    login dms_session_ids: { 'd3' => 'token' }
    ended = nil
    Dms.stub(:logout, ->(session_ids) { ended = session_ids }) { delete logins_url }
    assert_redirected_to new_logins_url
    assert_equal({ 'd3' => 'token' }, ended)
    assert_nil session[:dms_session_id]
  end

  test 'ending change user keeps d.3 session of admin' do
    login username: :admin, dms_session_ids: { 'd3' => 'token' }
    patch logins_url, params: { login: { user_id: user(:one).id } }
    assert_redirected_to root_path
    Dms.stub(:logout, ->(*) { flunk 'd.3-Session darf nicht beendet werden' }) { delete logins_url }
    assert_redirected_to root_path
    assert_equal({ 'd3' => 'token' }, session[:dms_session_id])
  end

  test 'switching to auth code ends d.3 session' do
    login dms_session_ids: { 'd3' => 'token' }
    ended = nil
    Dms.stub(:logout, ->(session_ids) { ended ||= session_ids }) { get "/issues?auth_code=#{auth_code(:one).uuid}" }
    assert_response :success
    assert_equal({ 'd3' => 'token' }, ended)
    assert_nil session[:dms_session_id]
  end

  private

  def post_login(login, password: 'Bfpi', dms_login: {})
    Dms.stub(:login, dms_login) { post logins_url, params: { login: { login:, password: } } }
  end
end
