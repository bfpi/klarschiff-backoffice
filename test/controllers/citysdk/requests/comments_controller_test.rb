# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test 'index without api-key' do
    get "/citysdk/requests/comments/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'index with invalid api-key' do
    get "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'index with api-key frontend' do
    get "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'index with api-key ppc' do
    get "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert doc.xpath('/comments/comment/id').count.positive?
  end

  test 'create without attributes' do
    post "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_frontend}",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/comments/comment/id').count
  end

  test 'reject create without privacy_policy_accepted if required' do
    configure_privacy_settings(active: true)
    post "/citysdk/requests/comments/#{issue(:one).id}.xml?api_key=#{api_key_frontend}",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end
end
