# frozen_string_literal: true

require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post "/citysdk/requests/votes/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post "/citysdk/requests/votes/#{issue(:one).id}.xml", params: { author: 'test@example.com' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/votes/vote/id').count
  end

  test 'reject create without privacy_policy_accepted if required' do
    with_privacy_settings(active: true) do
      post "/citysdk/requests/votes/#{issue(:one).id}.xml", params: { author: 'test@example.com' }
      assert_privacy_acceptence_validation Nokogiri::XML(response.parsed_body)
    end
  end

  test 'confirm' do
    put "/citysdk/requests/votes/#{supporter(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/votes/#{supporter(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/votes/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end
end
