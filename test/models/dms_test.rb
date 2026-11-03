# frozen_string_literal: true

require 'test_helper'

class DmsTest < ActiveSupport::TestCase
  ADDRESS = Geocodr::LabelFormatter::Address.new(
    street_name: 'Lange Straße', street_key: '01234', place_name: 'Stadtmitte', housenumber: '1a'
  ).freeze

  setup do
    @issue = issue(:received)
    Current.user = user(:one)
  end

  test 'enabled only for configured target with category' do
    cases = { 'd3:AAUTO' => true, 'd3' => false, 'dms' => false, 'foo:AAUTO' => false, nil => false }
    cases.each { |value, enabled| assert_equal enabled, dms(value:).enabled?, value.inspect }
  end

  test 'lookup returns link to existing document' do
    api = Minitest::Mock.new
    api.expect(:search, 'P000123', category: 'AAUTO', property: search_property, value: @issue.id, session_id: 'token')
    api.expect(:document_url, 'https://d3.example/o2/P000123', ['P000123'])
    assert_equal Dms::Result.new(:found, 'https://d3.example/o2/P000123'), lookup_with(api)
    api.verify
  end

  test 'lookup returns encoded create link if no document exists' do
    @issue.property_owner = 'Müller & Söhne'
    api = Minitest::Mock.new
    api.expect(:search, nil, category: 'AAUTO', property: search_property, value: @issue.id, session_id: 'token')
    result = Geocodr.stub(:address_dms, ADDRESS) { lookup_with(api) }
    assert_equal :not_found, result.status
    assert_equal create_link_params, URI.decode_www_form(URI.parse(result.url).query).to_h
    api.verify
  end

  test 'lookup is unavailable without d.3 session' do
    no_api = ->(*) { flunk 'd.3 darf ohne Session nicht aufgerufen werden' }
    result = DmsApi.stub(:new, no_api) { dms(session_ids: nil).lookup }
    assert_equal Dms::Result.new(:unavailable, nil), result
  end

  test 'lookup is unavailable and logs error if d.3 fails' do
    api = DmsApi.new({})
    log = capture_log do
      result = api.stub(:search, ->(**) { raise DmsApi::Error, 'HTTP 401' }) { lookup_with(api) }
      assert_equal :unavailable, result.status
    end
    assert_match 'HTTP 401', log
  end

  test 'lookup is unavailable if search property is not configured' do
    log = capture_log { assert_equal :unavailable, dms(value: 'd3:UNBEKANNT').lookup.status }
    assert_match 'KeyError', log
  end

  test 'login collects session ids of reachable targets' do
    api = DmsApi.new({})
    session_ids = api.stub(:login, 'token') { DmsApi.stub(:new, api) { Dms.login('max', 'geheim') } }
    assert_equal({ 'd3' => 'token' }, session_ids)
  end

  test 'login omits targets with failed authentication' do
    api = DmsApi.new({})
    session_ids = api.stub(:login, nil) { DmsApi.stub(:new, api) { Dms.login('max', 'geheim') } }
    assert_empty session_ids
  end

  test 'logout ends sessions of configured targets only' do
    api = Minitest::Mock.new
    api.expect(:logout, nil, ['token'])
    configs = []
    new_api = lambda do |config|
      configs << config
      api
    end
    DmsApi.stub(:new, new_api) { Dms.logout({ 'd3' => 'token', 'foo' => 'other' }) }
    assert_equal [Dms.config[:d3]], configs
    api.verify
  end

  test 'logout without session id does not call d.3' do
    calls = 0
    DmsApi.stub(:new, ->(*) { calls += 1 }) { [nil, {}, { 'd3' => '' }].each { |ids| Dms.logout(ids) } }
    assert_equal 0, calls
  end

  private

  def dms(value: 'd3:AAUTO', session_ids: { 'd3' => 'token' })
    @issue.stub(:dms, value) { Dms.new(@issue, session_ids:) }
  end

  def lookup_with(api, value: 'd3:AAUTO')
    DmsApi.stub(:new, api) { dms(value:).lookup }
  end

  def search_property
    Dms.config.dig(:d3, :search_property, :AAUTO)
  end

  def create_link_params
    {
      'ks_id' => @issue.id.to_s, 'ks_user' => user(:one).login, 'ks_str' => 'Lange Straße (01234 - Stadtmitte)',
      'ks_hnr' => '1', 'ks_hnr_z' => 'a', 'ks_eigentuemer' => 'Müller & Söhne'
    }
  end
end
