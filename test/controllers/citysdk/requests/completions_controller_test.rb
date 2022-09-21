# frozen_string_literal: true

require 'test_helper'

class CompletionsControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post "/citysdk/requests/completions/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'create' do
    post "/citysdk/requests/completions/#{issue(:one).id}.xml", params: { author: 'test3@example.com' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/completions/completion/id').count
  end

  test 'reject create without privacy_policy_accepted if required' do
    with_privacy_settings(active: true) do
      post "/citysdk/requests/completions/#{issue(:one).id}.xml", params: { author: 'test@example.com' }
      assert_privacy_acceptence_validation Nokogiri::XML(response.parsed_body)
    end
  end

  test 'confirm' do
    put "/citysdk/requests/completions/#{completion(:one).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/completions/#{completion(:confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/completions/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end
end
