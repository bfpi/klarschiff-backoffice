# frozen_string_literal: true

require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin].each do |role|
    test "authorized index for #{role}" do
      login username: role
      get '/groups'
      assert_response :success
    end

    test "does not create with missing required params for #{role}" do
      login username: role
      post '/groups', params: { group: { active: true, type: 'AuthorityGroup', kind: :internal } }, xhr: true
      assert_response :unprocessable_entity
    end
  end

  test 'not authorized index for editor' do
    login username: :editor
    get '/groups'
    assert_response :forbidden
  end
end
