# frozen_string_literal: true

require 'test_helper'

class MailBlacklistsControllerTest < ActionDispatch::IntegrationTest
  test 'authorized index as admin' do
    login username: 'admin'
    get '/mail_blacklists'
    assert_response :success
  end

  %i[regional_admin editor].each do |role|
    test "not authorized index as #{role}" do
      login username: role
      get '/mail_blacklists'
      assert_response :forbidden
    end
  end
end
