# frozen_string_literal: true

require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin editor].each do |role|
    test "authorized index for #{role}" do
      login username: role
      get '/issues'
      assert_response :success
    end
  end

  test 'not authorized index for editor without assigned issues' do
    login username: :editor2
    get '/issues'
    assert_response :forbidden
  end
end
