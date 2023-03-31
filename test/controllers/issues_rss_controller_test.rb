# frozen_string_literal: true

require 'test_helper'

class IssuesRssControllerTest < ActionDispatch::IntegrationTest
  test 'index for user with uuid' do
    assert_not user(:one)[:uuid].blank?
    get "/issues_rss/#{user(:one).uuid}.xml"
    assert_response :success
  end

  %w[dashboards delegations districts editorial_notifications feedbacks field_services groups issues mail_blacklists
     places responsibilities
     users].each do |controller|
    test "not authorized for user with uuid at #{controller} controller" do
      assert_not user(:one)[:uuid].blank?
      get "/issues/#{user(:one).uuid}.xml"
      assert_response :redirect
    end
  end
end
