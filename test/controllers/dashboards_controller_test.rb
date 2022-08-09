# frozen_string_literal: true

require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test 'show former issues for editor' do
    login username: :editor
    get '/dashboards'
    assert_response :success
    assert_equal [issue(:former_issue_one).id], @controller.view_assigns['former_issues'].ids
  end

  test 'show no former issues for admin without groups' do
    login username: :admin
    get '/dashboards'
    assert_response :success
    assert_equal [issue(:former_issue_one).id], @controller.view_assigns['former_issues'].ids
    user(:admin).update! groups: []
    get '/dashboards'
    assert_response :success
    assert_empty @controller.view_assigns['former_issues']
  end

  test 'show former issues for regional admin' do
    login username: :regional_admin
    get '/dashboards'
    assert_response :success
    assert_equal [issue(:former_issue_two).id], @controller.view_assigns['former_issues'].ids
  end
end
