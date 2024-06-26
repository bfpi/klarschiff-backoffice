# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def notification(issue:, to: nil, auth_code: nil)
    to ||= mailer_config.dig(:feedback_mailer, :notification, :to)
    @issue = issue
    @link = auth_code ? issue_url(issue.id, auth_code: auth_code.uuid) : issue_url(issue.id)
    mail(to:, interpolation: { subject: { number: issue.id } })
  end
end
