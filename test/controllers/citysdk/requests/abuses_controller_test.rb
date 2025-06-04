# frozen_string_literal: true

require 'test_helper'

class AbusesControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post "/citysdk/requests/abuses/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', '<%= I18n.t("test.controller.citydsk.error_422_message.validation_failed") %>'
  end

  test 'create' do
    post "/citysdk/requests/abuses/#{issue(:one).id}.xml", params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/abuses/abuse/id').count
  end

  test 'reject create without privacy_policy_accepted if required' do
    with_privacy_settings(active: true) do
      post "/citysdk/requests/abuses/#{issue(:one).id}.xml", params: { author: 'test@example.com', comment: 'abcde' }
      assert_privacy_acceptence_validation Nokogiri::XML(response.parsed_body)
    end
  end

  test 'confirm' do
    put "/citysdk/requests/abuses/#{abuse_report(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/abuses/#{abuse_report(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', '<%= I18n.t("test.controller.citysdk.error_404_message") %>'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/abuses/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', '<%= I18n.t("test.controller.citysdk.error_404_message") %>'
  end
end
