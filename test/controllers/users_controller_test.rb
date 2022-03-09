# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup { configure_password_settings(length: 4, included_characters: %i[lowercase capital]) }

  test 'authorized to change password' do
    login(username: :editor)
    put '/update_password', params: { user: { password: 'Bfpi2', password_confirmation: 'Bfpi2' } }
    assert_response :success
    login(username: :editor, password: 'Bfpi2')
  end

  test 'not authorized to change password for ldap_user' do
    login_as_ldap_user(username: :ldap_user)
    put '/update_password', params: { user: { password: 'Bfpi2', password_confirmation: 'Bfpi2' } }
    assert_response :forbidden
  end

  test 'authorized to change other user password as admin' do
    login(username: :admin)
    user = user(:editor)
    put "/users/#{user.id}", xhr: true, params: { user: { password: 'Test1', password_confirmation: 'Test1' } }
    assert_response :success
    login(username: :editor, password: 'Test1')
  end
end
