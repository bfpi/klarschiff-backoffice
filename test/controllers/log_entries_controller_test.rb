# frozen_string_literal: true

require 'test_helper'

class LogEntriesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin].each do |role|
    test "authorized index as #{role}" do
      login username: role
      get '/log_entries'
      assert_response :success
    end
  end

  test 'not authorized index as editor' do
    login username: 'editor'
    get '/log_entries'
    assert_response :forbidden
  end
end
