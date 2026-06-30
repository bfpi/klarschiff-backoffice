# frozen_string_literal: true

class ConfirmationMailer < ApplicationMailer
  def issue(to:, issue_id:, confirmation_hash:, with_photo: false)
    @with_photo = with_photo
    @confirmation_url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/issue"
    @delete_url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/revoke_issue"
    @issue_url = format("#{Settings::Instance.frontend_url}map?request=%d", issue_id)
    mail(to:, subject: default_i18n_subject(number: issue_id))
  end

  def supporter(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/vote"
    mail(to:, subject: default_i18n_subject(number: issue_id))
  end

  def abuse_report(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/abuse"
    mail(to:, subject: default_i18n_subject(number: issue_id))
  end

  def completion(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/completion"
    mail(to:, subject: default_i18n_subject(number: issue_id))
  end

  def photo(to:, issue_id:, confirmation_hash:)
    @url = "#{mailer_config[:confirmation_base_url]}/#{confirmation_hash}/photo"
    mail(to:, subject: default_i18n_subject(number: issue_id))
  end
end
