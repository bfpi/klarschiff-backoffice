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
end
