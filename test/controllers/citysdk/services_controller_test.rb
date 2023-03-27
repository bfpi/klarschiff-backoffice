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
end
