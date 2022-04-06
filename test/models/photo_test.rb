# frozen_string_literal: true

require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    photo = Photo.create(issue: issue(:one), author: 'test@rostock.de', status: 0, file: test_file)
    assert_valid photo
    assert_enqueued_email_with(
      ConfirmationMailer, :photo,
      args: [{ to: photo.author, confirmation_hash: photo.confirmation_hash, issue_id: photo.issue_id }]
    )
  end

  test 'validate author as email' do
    photo = Photo.new
    assert_not photo.valid?
    assert_equal [{ error: :blank }], photo.errors.details[:author]
    photo.author = 'abc'
    assert_not photo.valid?
    assert_equal [{ error: :email, value: 'abc' }], photo.errors.details[:author]
    photo.author = 'abc@example.com'
    photo.valid?
    assert_empty photo.errors.details[:author]
  end

  private

  def test_file
    Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/test.jpg'), 'image/jpg')
  end
end
