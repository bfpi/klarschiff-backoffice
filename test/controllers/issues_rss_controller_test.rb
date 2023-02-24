# frozen_string_literal: true

require 'test_helper'

class IssuesRssControllerTest < ActionDispatch::IntegrationTest
  test 'index for user with uuid' do
    assert_not user(:one)[:uuid].blank?
    get "/issues_rss/#{user(:one).uuid}.xml"
    assert_response :success
  end

  test 'index for user without uuid' do
    assert_predicate user(:two)[:uuid], :blank?
    get "/issues_rss/#{user(:two).uuid}.xml"
    assert_response :success
    assert_not user(:two).reload[:uuid].blank?
  end
end
