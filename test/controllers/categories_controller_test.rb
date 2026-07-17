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

    test "not authorized destroy for #{role} without manage categories" do
      with_manage_categories_settings(manage_categories: false) do
        login username: role
        assert_no_changes 'category(:one).reload' do
          delete "/categories/#{category(:one).id}"
          assert_response :forbidden
        end
      end
    end

    test "not authorized reactivate for #{role} without manage categories" do
      with_manage_categories_settings(manage_categories: false) do
        login username: role
        assert_no_changes 'category(:deleted_at).reload' do
          get "/categories/#{category(:deleted_at).id}/reactivate"
          assert_response :forbidden
        end
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

    test "not authorized destroy for #{role}" do
      with_manage_categories_settings(manage_categories: true) do
        login username: role
        assert_no_changes 'category(:one).reload' do
          delete "/categories/#{category(:one).id}"
          assert_response :forbidden
        end
      end
    end

    test "not authorized reactivate for #{role}" do
      with_manage_categories_settings(manage_categories: true) do
        login username: role
        assert_no_changes 'category(:deleted_at).reload' do
          get "/categories/#{category(:deleted_at).id}/reactivate"
          assert_response :forbidden
        end
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
      assert_changes 'category(:one).reload.deleted_at', from: nil do
        delete "/categories/#{category(:one).id}"
        assert_redirected_to categories_path
      end
    end
  end

  test 'authorized reactivate for admin' do
    with_manage_categories_settings(manage_categories: true) do
      login username: 'admin'
      assert_changes 'category(:deleted_at).reload.deleted_at', to: nil do
        get "/categories/#{category(:deleted_at).id}/reactivate"
        assert_redirected_to categories_path
      end
    end
  end
end
