# frozen_string_literal: true

require 'test_helper'

class PhotosControllerTest < ActionDispatch::IntegrationTest
  test 'create without attributes' do
    post "/citysdk/requests/photos/#{issue(:one).id}.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
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

  test 'create with multiple photos' do
    assert_difference 'Photo.unscoped.count', 2 do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml",
        params: { author: 'test@example.com', media: Array.new(2) { encoded_test_file } }
      assert_response :created
    end
    doc = Nokogiri::XML(response.parsed_body)
    ids = doc.xpath('/photos/photo/id/text()').map(&:to_s)
    assert_equal 2, ids.uniq.size
    assert_equal 2, Photo.unscoped.where(id: ids, issue: issue(:one), status: :internal).count
    assert_equal 2, Photo.unscoped.where(id: ids).distinct.count(:confirmation_hash)
    assert_enqueued_emails 2
  end

  test 'create with photo array with blank entries' do
    assert_difference 'Photo.unscoped.count', 1 do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml",
        params: { author: 'test@example.com', media: ['', encoded_test_file, ''] }
      assert_response :created
    end
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/photos/photo/id').count
  end

  test 'create with blank media entries only' do
    assert_no_difference 'Photo.unscoped.count' do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml", params: { author: 'test@example.com', media: ['', ''] }
    end
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
  end

  test 'reject create with multiple photos without author' do
    assert_no_difference 'Photo.unscoped.count' do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml", params: { media: Array.new(2) { encoded_test_file } }
    end
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '422', 'Gültigkeitsprüfung ist fehlgeschlagen'
    assert_no_enqueued_emails
  end

  test 'reject create with an invalid image among multiple photos' do
    assert_no_difference 'Photo.unscoped.count' do
      post "/citysdk/requests/photos/#{issue(:one).id}.xml",
        params: { author: 'test@example.com', media: [encoded_test_file, Base64.encode64('no image')] }
    end
    assert_not response.successful?
    assert_no_enqueued_emails
  end

  test 'create with multiple photos as json array' do
    create_params = { author: 'test@example.com', media: Array.new(2) { encoded_test_file } }
    assert_difference 'Photo.unscoped.count', 2 do
      post "/citysdk/requests/photos/#{issue(:one).id}.json", params: create_params.to_json,
        headers: { 'CONTENT_TYPE' => 'application/json' }
    end
    assert_response :created
    assert_equal 2, response.parsed_body.distinct.pluck('id').size
  end

  test 'create with a single photo as json returns a single object' do
    create_params = { author: 'test@example.com', media: encoded_test_file }
    assert_difference 'Photo.unscoped.count', 1 do
      post "/citysdk/requests/photos/#{issue(:one).id}.json", params: create_params.to_json,
        headers: { 'CONTENT_TYPE' => 'application/json' }
    end
    assert_response :created
    assert_predicate response.parsed_body['id'], :present?
  end

  test 'confirm' do
    put "/citysdk/requests/photos/#{photo(:unconfirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_equal 1, doc.xpath('/service_requests/request/service_request_id').count
  end

  test 'confirm already confirmed hash' do
    put "/citysdk/requests/photos/#{photo(:already_confirmed).confirmation_hash}/confirm.xml"
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  test 'confirm invalid hash' do
    put '/citysdk/requests/photos/abcdefghijklmnopqrstuvwxyz/confirm.xml'
    doc = Nokogiri::XML(response.parsed_body)
    assert_error_messages doc, '404', 'record_not_found'
  end

  private

  def encoded_test_file
    Base64.encode64(Rails.root.join('test/fixtures/files/test.jpg').binread)
  end
end
