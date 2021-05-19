# frozen_string_literal: true

class ConfirmationMailer < ApplicationMailer
  def issue(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/issue"
    mail(to: to, interpolation: { subject: { number: issue_id } })
  end

  def supporter(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/vote"
    mail(to: to, interpolation: { subject: { number: issue_id } })
  end

  def abuse_report(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/abuse"
    mail(to: to, interpolation: { subject: { number: issue_id } })
  end

  def photo(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/photo"
    mail(to: to, interpolation: { subject: { number: issue_id } })
  end
end
