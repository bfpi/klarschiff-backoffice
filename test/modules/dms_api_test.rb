# frozen_string_literal: true

require 'test_helper'

class DmsApiTest < ActiveSupport::TestCase
  class FakeHttp
    attr_accessor :use_ssl, :open_timeout, :read_timeout, :write_timeout, :max_retries
    attr_reader :requests

    def initialize(response)
      @response = response
      @requests = []
    end

    def request(request)
      @requests << request
      raise @response if @response.is_a?(Exception)
      @response
    end
  end

  setup do
    @config = Dms.config[:d3]
    @api = DmsApi.new(@config)
  end

  test 'login sends basic auth and returns session id on status 200' do
    with_http(http_response(200, cookies: ['AuthSessionId=abc123; Path=/; Secure; HttpOnly'])) do |http|
      assert_equal 'abc123', @api.login('max', 'geheim')
      request = http.requests.sole
      assert_equal "#{@config[:api]}/identityprovider/login/", request.uri.to_s
      assert_equal "Basic #{['max:geheim'].pack('m0')}", request['Authorization']
      assert_equal 'application/json', request['Accept']
    end
  end

  test 'login uses configured timeout without retries' do
    api = DmsApi.new(@config.merge(timeout: 12))
    with_http(http_response(200, cookies: ['AuthSessionId=abc123'])) do |http|
      api.login('max', 'geheim')
      assert_equal [12, 12, 12, 0], [http.open_timeout, http.read_timeout, http.write_timeout, http.max_retries]
      assert http.use_ssl
    end
  end

  test 'login fails silently and logs on status other than 200' do
    log = capture_log do
      with_http(http_response(401, cookies: ['AuthSessionId=abc123'])) { assert_nil @api.login('max', 'geheim') }
    end
    assert_match 'HTTP 401', log
    assert_no_match 'geheim', log
  end

  test 'login fails silently without session cookie' do
    with_http(http_response(200, cookies: ['OtherCookie=xyz'])) { assert_nil @api.login('max', 'geheim') }
  end

  test 'login fails silently and logs on timeout' do
    log = capture_log do
      with_http(Net::OpenTimeout.new('execution expired')) { assert_nil @api.login('max', 'geheim') }
    end
    assert_match 'Net::OpenTimeout', log
  end

  test 'logout sends session cookie to logout endpoint' do
    with_http(http_response(200)) do |http|
      @api.logout('token')
      request = http.requests.sole
      assert_equal 'GET', request.method
      assert_equal "#{@config[:api]}/identityprovider/logout", request.uri.to_s
      assert_equal 'AuthSessionId=token', request['Cookie']
    end
  end

  test 'logout accepts success and redirect without logging' do
    [200, 204, 302].each do |code|
      log = capture_log { with_http(http_response(code)) { @api.logout('token') } }
      assert_empty log, "HTTP #{code}"
    end
  end

  test 'logout fails silently and logs on status other than 2xx or 3xx' do
    log = capture_log { with_http(http_response(401)) { @api.logout('token') } }
    assert_match 'HTTP 401', log
  end

  test 'logout fails silently and logs on timeout' do
    log = capture_log { with_http(Net::ReadTimeout.new) { @api.logout('token') } }
    assert_match 'Net::ReadTimeout', log
  end

  test 'search sends category, property and session cookie' do
    with_http(http_response(200, body: { items: [] }.to_json)) do |http|
      search
      request = http.requests.sole
      query = URI.decode_www_form(request.uri.query).to_h
      assert_equal "/dms/r/#{@config[:repository]}/srm", request.uri.path
      assert_equal 'AuthSessionId=token', request['Cookie']
      assert_equal "/dms/r/#{@config[:repository]}/source", query['sourceId']
      assert_equal ['AAUTO'], JSON.parse(query['sourceCategories'])
      assert_equal({ search_property => ['4711'] }, JSON.parse(query['sourceProperties']))
    end
  end

  test 'search returns id of first hit' do
    body = { items: [{ id: 'P000123' }, { id: 'P000456' }] }.to_json
    with_http(http_response(200, body:)) { assert_equal 'P000123', search }
  end

  test 'search returns nil without hit' do
    [{ items: [] }, {}].each do |body|
      with_http(http_response(200, body: body.to_json)) { assert_nil search }
    end
  end

  test 'search raises error on status other than 200' do
    with_http(http_response(401)) { assert_raises(DmsApi::Error) { search } }
  end

  test 'document_url builds direct link' do
    assert_equal "#{@config[:api]}/dms/r/#{@config[:repository]}/o2/P000123", @api.document_url('P000123')
  end

  private

  def search
    @api.search(category: 'AAUTO', property: search_property, value: 4711, session_id: 'token')
  end

  def search_property
    @config.dig(:search_property, :AAUTO)
  end

  def with_http(response)
    http = FakeHttp.new(response)
    Net::HTTP.stub(:new, http) { yield http }
  end

  def http_response(code, body: nil, cookies: [])
    Net::HTTPResponse::CODE_TO_OBJ.fetch(code.to_s).new('1.1', code.to_s, '').tap do |response|
      cookies.each { |cookie| response.add_field('Set-Cookie', cookie) }
      response.instance_variable_set(:@body, body)
      response.instance_variable_set(:@read, true)
    end
  end
end
