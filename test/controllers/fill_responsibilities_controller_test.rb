# frozen_string_literal: true

require 'test_helper'

class FillResponsibilitiesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin].each do |role|
    test "new for #{role}" do
      login username: role
      get '/fill_responsibilities/new', xhr: true
      assert_response :success
    end
  end

  test 'not authorized new for editor' do
    login username: :editor
    get '/fill_responsibilities/new'
    assert_response :forbidden
  end

  test 'does not create with missing required param' do
    login username: :regional_admin2
    post '/fill_responsibilities', xhr: true
    assert_response :unprocessable_entity
  end

  test 'does not create with invalid required param' do
    login username: :regional_admin
    post '/fill_responsibilities', params: { responsibility: { group_id: group(:two).id } }, xhr: true
    assert_response :unprocessable_entity
  end

  test 'does not create with invalid external required param' do
    login username: :regional_admin
    post '/fill_responsibilities', params: { responsibility: { group_id: group(:external2).id } }, xhr: true
    assert_response :unprocessable_entity
  end

  test 'create with valid param' do
    login username: :regional_admin2
    post '/fill_responsibilities', params: { responsibility: { group_id: group(:one).id } }, xhr: true
    assert_response :success
    assert_redirected_to responsibilities_path
  end
end
