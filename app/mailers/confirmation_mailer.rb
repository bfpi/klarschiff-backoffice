# frozen_string_literal: true

class ConfirmationMailer < ApplicationMailer
  def issue(to:, issue_id:, confirmation_hash:, with_photo: false)
    @with_photo = with_photo
    @confirmation_url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/issue"
    @delete_url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/revoke_issue"
    @issue_url = Settings::Instance.frontend_issue_url % issue_id
    mail(to:, interpolation: { subject: { number: issue_id } })
  end

  def supporter(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/vote"
    mail(to:, interpolation: { subject: { number: issue_id } })
  end

  def abuse_report(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/abuse"
    mail(to:, interpolation: { subject: { number: issue_id } })
  end

  def photo(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/photo"
    mail(to:, interpolation: { subject: { number: issue_id } })
  end
end
