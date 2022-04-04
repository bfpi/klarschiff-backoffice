# frozen_string_literal: true

require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup { configure_privacy_settings }

  test 'index without api-key' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'index with invalid api-key' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', 'Der übergebene API-Key ist ungültig.'
  end

  test 'index with api-key frontend' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'index with api-key ppc' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert doc.xpath('/notes/note/id').count.positive?
  end

  test 'create without api-key' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', 'Es wurde kein API-Key übergeben.'
  end

  test 'create with api-key frontend' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_frontend}",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403',
      'Mit dem übergebenen API-Key stehen die benötigten Zugriffsrechte nicht zur Verfügung.'
  end

  test 'create without attributes' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { author: 'one@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/notes/note/id').count
  end

  test 'create with invalid author' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { author: 'unknown@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create without author' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create without comment' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { author: 'test@example.com' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'reject create without privacy_policy_accepted if required' do
    configure_privacy_settings(active: true)
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { author: 'one@example.com', comment: 'abcde' }
    assert_privacy_acceptence_validation Nokogiri::XML(response.parsed_body)
  end
end
