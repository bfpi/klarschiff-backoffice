# frozen_string_literal: true

require 'test_helper'

class ResponsibilitiesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin].each do |role|
    test "authorized index for #{role}" do
      login username: role
      get '/responsibilities'
      assert_response :success
    end

    test "new without category_id for #{role}" do
      login username: role
      get '/responsibilities/new', xhr: true
      assert_response :success
    end

    test "new with category_id for #{role}" do
      login username: role
      get "/categories/#{category(:one).id}/responsibilities/new", xhr: true
      assert_response :success
    end
  end

  test 'not authorized index for editor' do
    login username: :editor
    get '/responsibilities'
    assert_response :forbidden
  end

  test 'new without category_id for editor' do
    login username: :editor
    get '/responsibilities/new', xhr: true
    assert_response :forbidden
  end

  test 'new with category_id for editor' do
    login username: :editor
    get "/categories/#{category(:one).id}/responsibilities/new", xhr: true
    assert_response :forbidden
  end
end
