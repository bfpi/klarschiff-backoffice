# frozen_string_literal: true

require 'test_helper'

class AbusesControllerTest < ActionDispatch::IntegrationTest
  setup { configure_privacy_settings }

  test 'create without attributes' do
    post "/citysdk/requests/abuses/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post "/citysdk/requests/abuses/#{issue(:one).id}.xml", params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/abuses/abuse/id').count
  end

  test 'create without privacy_policy_accepted' do
    configure_privacy_settings(active: true)
    post "/citysdk/requests/abuses/#{issue(:one).id}.xml", params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'confirm' do
    put "/citysdk/requests/abuses/#{abuse_report(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/abuses/#{abuse_report(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/abuses/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end
end
