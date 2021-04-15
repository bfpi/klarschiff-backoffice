# frozen_string_literal: true

require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send mail after create' do
    photo = Photo.create(issue: issue(:one), author: 'test@rostock.de', status: 0, file: test_file)
    assert photo.valid?
    assert_enqueued_email_with(
      ConfirmationMailer, :photo,
      args: [{ to: photo.author, confirmation_hash: photo.confirmation_hash, issue_id: photo.issue_id }]
    )
  end

  private

  def test_file
    Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/test.jpg'), 'image/jpg')
  end
end
