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
    get '/citysdk/areas.xml', params: { regional_key: :one, search_class: 'authority' }
    doc = Nokogiri::XML(response.parsed_body)
    areas = doc.xpath('/areas/area')
    assert_predicate areas.count, :positive?
  end

  test 'index with default area-level' do
    with_parent_instance_settings do
      get '/citysdk/areas.xml', params: { with_districts: true }
      doc = Nokogiri::XML(response.parsed_body)
      areas = doc.xpath('/areas/area/name/text()').map(&:to_s).select { |t| t.starts_with? 'Authority' }
      assert_predicate areas.count, :positive?
    end
  end

  test 'index with parent_instance area-level' do
    with_parent_instance_settings(url: 'http://www.example.com') do
      get '/citysdk/areas.xml', params: { with_districts: true }
      doc = Nokogiri::XML(response.parsed_body)
      areas = doc.xpath('/areas/area/name/text()').map(&:to_s).select { |t| t.starts_with? 'District' }
      assert_predicate areas.count, :positive?
    end
  end

  test 'index with invalid search_class' do
    get '/citysdk/areas.xml', params: { search_class: 'ABCDE' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '500', 'Suchklasse ungültig'
  end
end
