# frozen_string_literal: true

class FeedbackMailerPreview < ActionMailer::Preview
  def notification
    FeedbackMailer.notification issue: Issue.first, to: 'test@bfpi.de'
  end

  def notification_to_default_recipient
    FeedbackMailer.notification issue: Issue.first
  end

  def notification_with_auth_code
    FeedbackMailer.notification issue: Issue.first, to: 'test@bfpi.de', auth_code: AuthCode.new(uuid: SecureRandom.uuid)
  end
end
