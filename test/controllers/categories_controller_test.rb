# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  %i[admin regional_admin editor].each do |role|
    test "not authorized index for #{role} without manage categories" do
      with_manage_categories_settings(manage_categories: false) do
        login username: role
        get '/categories'
        assert_response :forbidden
      end
    end
  end

  %i[regional_admin editor].each do |role|
    test "not authorized index for #{role}" do
      with_manage_categories_settings(manage_categories: true) do
        login username: role
        get '/categories'
        assert_response :forbidden
      end
    end
  end

  test 'authorized index for admin' do
    with_manage_categories_settings(manage_categories: true) do
      login username: :admin
      get '/categories'
      assert_response :success
    end
  end

  test 'authorized destroy for admin' do
    with_manage_categories_settings(manage_categories: true) do
      login username: 'admin'
      assert_nil category(:one).deleted_at
      delete "/categories/#{category(:one).id}"
      assert_redirected_to categories_path
      assert_not_nil category(:one).reload.deleted_at
    end
  end

  test 'authorized reactivate for admin' do
    with_manage_categories_settings(manage_categories: true) do
      login username: 'admin'
      assert_not_nil category(:deleted_at).deleted_at
      get "/categories/#{category(:deleted_at).id}/reactivate"
      assert_redirected_to categories_path
      assert_nil category(:deleted_at).reload.deleted_at
    end
  end
end
