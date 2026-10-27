# frozen_string_literal: true

require 'test_helper'

class DmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @issue = issue(:received)
  end

  test 'shows button to existing d.3 document' do
    login username: :admin, dms_session_ids: { 'd3' => 'token' }
    request_dms 'P000123'
    assert_response :success
    assert_select 'a.btn[href=?]', "#{d3_config[:api]}/dms/r/#{d3_config[:repository]}/o2/P000123",
      text: 'Akte in d.3 aufrufen'
  end

  test 'shows button to create d.3 document if none exists' do
    login username: :admin, dms_session_ids: { 'd3' => 'token' }
    Geocodr.stub(:address_dms, nil) { request_dms nil }
    assert_response :success
    assert_select 'a.btn[href^=?]', d3_config.dig(:create_link, :AAUTO).split('?').first,
      text: 'neue Akte in d.3 anlegen'
  end

  test 'shows hint without d.3 session' do
    login username: :admin
    request_dms(->(**) { flunk 'd.3 darf ohne Session nicht aufgerufen werden' })
    assert_response :success
    assert_select 'a', count: 0
    assert_select 'span', text: 'Kommunikation mit d.3 momentan nicht möglich'
  end

  test 'shows hint if d.3 is not reachable' do
    login username: :admin, dms_session_ids: { 'd3' => 'token' }
    request_dms(->(**) { raise DmsApi::Error, 'HTTP 503' })
    assert_response :success
    assert_select 'span', text: 'Kommunikation mit d.3 momentan nicht möglich'
  end

  private

  def d3_config
    Dms.config[:d3]
  end

  def request_dms(search_result)
    api = DmsApi.new(d3_config)
    @issue.stub(:dms, 'd3:AAUTO') do
      Issue.stub(:find, @issue) do
        api.stub(:search, search_result) do
          DmsApi.stub(:new, api) { get dms_index_path(issue_id: @issue.id) }
        end
      end
    end
  end
end
