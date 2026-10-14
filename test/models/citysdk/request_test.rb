# frozen_string_literal: true

require 'test_helper'

module Citysdk
  class RequestTest < ActiveSupport::TestCase
    test 'scope authorized contains no objects with soft deleted categories' do
      deleted_category = category(:deleted_at)
      assert Request.exists?(category_id: deleted_category.id)
      assert_not Request.authorized(tips: false).exists?(category_id: deleted_category.id)
      assert_not Request.authorized(tips: true).exists?(category_id: deleted_category.id)
    end

    test 'media= with a single string creates one upload and resets photo_required' do
      request = Request.new(photo_required: true)
      request.media = encoded_test_file
      assert_equal 1, request.new_photo.size
      assert_equal 'filename.jpg', request.new_photo.first.original_filename
      assert_equal 'image/jpeg', request.new_photo.first.content_type
      assert_not request.photo_required
    end

    test 'media= with an array creates one upload per entry' do
      request = Request.new
      request.media = Array.new(3) { encoded_test_file }
      assert_equal 3, request.new_photo.size
      assert_equal 3, request.new_photo.map(&:path).uniq.size
    end

    test 'media= ignores blank entries' do
      request = Request.new
      request.media = ['', nil, encoded_test_file]
      assert_equal 1, request.new_photo.size
    end

    test 'media= without any photo keeps photo_required' do
      request = Request.new(photo_required: true)
      request.media = ['', '']
      assert_nil request.new_photo
      assert request.photo_required
    end

    private

    def encoded_test_file
      Base64.encode64(Rails.root.join('test/fixtures/files/test.jpg').binread)
    end
  end
end
