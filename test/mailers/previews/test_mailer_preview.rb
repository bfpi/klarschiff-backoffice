# frozen_string_literal: true

class TestMailerPreview < ActionMailer::Preview
  def test
    TestMailer.test to: 'recipient@example.com'
  end
end
