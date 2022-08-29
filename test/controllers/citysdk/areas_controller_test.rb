# frozen_string_literal: true

require 'test_helper'

class AreasControllerTest < ActionDispatch::IntegrationTest
  test 'index' do
    get '/citysdk/areas.xml'
    doc = Nokogiri::XML(response.parsed_body)
    areas = doc.xpath('/areas/area')
    assert_equal 1, areas.count
  end

  test 'index with_districts' do
    get '/citysdk/areas.xml?with_districts=true'
    doc = Nokogiri::XML(response.parsed_body)
    areas = doc.xpath('/areas/area')
    assert_equal 2, areas.count
  end

  test 'index with valid search_class' do
    get "/citysdk/areas.xml", params: { regional_key: :one, search_class: 'authority' }
    doc = Nokogiri::XML(response.parsed_body)
    areas = doc.xpath('/areas/area')
    assert areas.count.positive?
  end

  test 'index with invalid search_class' do
    get "/citysdk/areas.xml", params: { search_class: 'ABCDE' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '500', 'search_class invalid'
  end
end
