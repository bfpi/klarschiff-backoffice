# frozen_string_literal: true

require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  test 'index without api-key' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', '<%= I18n.t("test.controller.citysdk.error_400_message") %>'
  end

  test 'index with invalid api-key' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_invalid}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '401', '<%= I18n.t("test.controller.citysdk.error_401_message") %>'
  end

  test 'index with api-key frontend' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_frontend}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403', '<%= I18n.t("test.controller.citysdk.error_403_message") %>'
  end

  test 'index with api-key ppc' do
    get "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_predicate doc.xpath('/notes/note/id').count, :positive?
  end

  test 'create without api-key' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '400', '<%= I18n.t("test.controller.citysdk.error_400_message") %>'
  end

  test 'create with api-key frontend' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_frontend}",
      params: { author: 'test@example.com', comment: 'abcde' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '403', '<%= I18n.t("test.controller.citysdk.error_403_message") %>'
  end

  test 'create without attributes' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', '<%= I18n.t("test.controller.citysdk.error_422_message.validation_failed") %>'
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
    assert_error_messages doc, '422', '<%= I18n.t("test.controller.citysdk.error_422_message.validation_failed") %>'
  end

  test 'create without comment' do
    post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
      params: { author: 'test@example.com' }
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', '<%= I18n.t("test.controller.citysdk.error_422_message.validation_failed") %>'
  end

  test 'reject create without privacy_policy_accepted if required' do
    with_privacy_settings(active: true) do
      post "/citysdk/requests/notes/#{issue(:one).id}.xml?api_key=#{api_key_ppc}",
        params: { author: 'one@example.com', comment: 'abcde' }
      assert_privacy_acceptence_validation Nokogiri::XML(response.parsed_body)
    end
  end
end
