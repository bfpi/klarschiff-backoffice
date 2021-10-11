# frozen_string_literal: true

require 'test_helper'

class CoverageControllerTest < ActionDispatch::IntegrationTest
  test 'call without position' do
    get '/citysdk/coverage.xml'
    doc = Nokogiri::XML(response.parsed_body)
    result = doc.xpath('/hash/result/text()')
    assert_equal 'false', result.to_s
    assert_empty doc.xpath('/hash/instance_url/text()')
  end

  test 'call with hro position' do
    get '/citysdk/coverage.xml?lat=54.09104309547743&long=12.122439338030057'
    doc = Nokogiri::XML(response.parsed_body)
    result = doc.xpath('/hash/result/text()')
    assert_equal 'false', result.to_s
    assert_not doc.xpath('/hash/instance_url/text()').blank?
  end

  test 'call with sn position' do
    get '/citysdk/coverage.xml?lat=53.6358415&long=11.4081669'
    doc = Nokogiri::XML(response.parsed_body)
    result = doc.xpath('/hash/result/text()')
    assert_equal 'false', result.to_s
    assert_not doc.xpath('/hash/instance_url/text()').blank?
  end

  test 'call with mv position' do
    get '/citysdk/coverage.xml?lat=53.9271214&long=11.972225'
    doc = Nokogiri::XML(response.parsed_body)
    result = doc.xpath('/hash/result/text()')
    assert_equal 'true', result.to_s
    assert doc.xpath('/hash/instance_url/text()').blank?
  end

  test 'call with invalid position' do
    get '/citysdk/coverage.xml?lat=52.5069313&long=13.1445632'
    doc = Nokogiri::XML(response.parsed_body)
    result = doc.xpath('/hash/result/text()')
    assert_equal 'false', result.to_s
    assert doc.xpath('/hash/instance_url/text()')
  end
end
