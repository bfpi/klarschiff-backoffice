# frozen_string_literal: true

require 'test_helper'

class IssuesRssControllerTest < ActionDispatch::IntegrationTest
  test 'index for user with uuid' do
    uuid = user(:one)[:uuid]
    assert_predicate uuid, :present?
    get "/issues_rss/#{uuid}.xml"
    assert_response :success
  end

  %w[delegations issues].each do |controller|
    test "not authorized for user with uuid at #{controller} controller" do
      uuid = user(:one)[:uuid]
      assert_predicate uuid, :present?
      get "/#{controller}/#{uuid}.xml"
      assert_response :redirect
      assert_redirected_to new_logins_url
    end
  end
end
