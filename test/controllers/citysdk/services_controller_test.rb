# frozen_string_literal: true

require 'test_helper'

class ServicesControllerTest < ActionDispatch::IntegrationTest
  test 'index without api-key' do
    get '/citysdk/services.xml'
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service')
    assert_not_empty services
  end

  test 'index with invalid api-key' do
    get "/citysdk/services.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'index with api-key frontend' do
    get "/citysdk/services.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service')
    assert_predicate services.count, :positive?
    document_url = doc.xpath('/services/service/document_url')
    assert_empty document_url
  end

  test 'index with api-key ppc' do
    get "/citysdk/services.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    document_url = doc.xpath('/services/service/document_url')
    assert_not_empty document_url
  end

  test 'show without api-key' do
    get "/citysdk/services/#{category(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/service_definition/service')
    assert_predicate services.count, :positive?
  end

  test 'show with invalid api-key' do
    get "/citysdk/services/#{category(:one).id}.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'show with api-key frontend' do
    get "/citysdk/services/#{category(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/service_definition/service')
    assert_predicate services.count, :positive?
    document_url = doc.xpath('/service_definition/service/document_url')
    assert_empty document_url
  end

  test 'show with api-key ppc' do
    get "/citysdk/services/#{category(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    document_url = doc.xpath('/service_definition/service/document_url')
    assert_not_empty document_url
  end

  test "index with group filter" do
    get '/citysdk/services.xml', params: { group: main_category(:one).to_s }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :positive?
    assert_not_includes services, category(:four).id.to_s
  end

  test "index with invalid group filter" do
    get '/citysdk/services.xml', params: { group: 'ABC' }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :zero?
  end

  test "index with keyword filter" do
    get '/citysdk/services.xml', params: { keyword: 'idea' }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :positive?
  end

  test "index with invalid keyword filter" do
    get '/citysdk/services.xml', params: { keyword: 'ABC' }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :zero?
  end

  test "index with lat and lon filter for api_key_frontend" do
    get '/citysdk/services.xml', params: { lat: 53.9784103, long: 11.8705908 }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :positive?
    assert_includes services, category(:four).id.to_s
  end

  test "index with lat and lon filter outside for api_key_frontend" do
    get '/citysdk/services.xml', params: { lat: 54.1079752, long: 11.7406435 }
    doc = Nokogiri::XML(response.parsed_body)
    services = doc.xpath('/services/service/service_code').map(&:text)
    assert_predicate services.count, :positive?
    assert_not_includes services, category(:four).id.to_s
  end

  [:api_key_ppc, :api_key_frontend, nil].each do |api_key_name|
    test "index returns no inactive service for api-key #{api_key_name}" do
      get '/citysdk/services.xml', params: api_key_name ? { api_key: send(api_key_name) } : {}
      service_codes = Nokogiri::XML(response.parsed_body).xpath('/services/service/service_code')
      assert_predicate service_codes.count, :positive?
      assert_empty Service.joins(:main_category, :sub_category).where(
        MainCategory.arel_table[:deleted].eq(true).or(SubCategory.arel_table[:deleted].eq(true))
      ).where(id: service_codes.map(&:text))
    end

    %i[deleted deleted_main_category deleted_sub_category].each do |category_key|
      test "show for inactive service #{category_key} for api-key #{api_key_name}" do
        get "/citysdk/services/#{category(category_key).id}.xml",
          params: api_key_name ? { api_key: send(api_key_name) } : {}
        service_codes = Nokogiri::XML(response.parsed_body).xpath('/service_definition/service/service_code')
        assert_predicate service_codes.count, :positive?
        assert_not_empty Service.joins(:main_category, :sub_category).where(
          MainCategory.arel_table[:deleted].eq(true).or(SubCategory.arel_table[:deleted].eq(true))
        ).where(id: service_codes.map(&:text))
      end
    end
  end

  test 'service without photo_requested' do
    get "/citysdk/services/#{category(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    photo_requested = doc.xpath('/service_definition/service/photo_requested').map(&:text).first
    assert_equal 'false', photo_requested
  end

  test 'service with photo_requested' do
    get "/citysdk/services/#{category(:photo_requested).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    photo_requested = doc.xpath('/service_definition/service/photo_requested').map(&:text).first
    assert_equal 'true', photo_requested
  end

end
