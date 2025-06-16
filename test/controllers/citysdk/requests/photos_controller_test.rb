# frozen_string_literal: true

require 'test_helper'

class PhotosControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post "/citysdk/requests/photos/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen.'
  end

  test 'create' do
    assert_difference 'Photo.unscoped.count' do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml",
        params: { author: 'test@example.com',
                  media: Base64.encode64(File.read('test/fixtures/files/test.jpg')) }
      assert_response :created
    end
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/photos/photo/id').count
  end

  test 'confirm' do
    put "/citysdk/requests/photos/#{photo(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/photos/#{photo(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'Datensatz nicht gefunden.'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/photos/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'Datensatz nicht gefunden.'
  end
end
