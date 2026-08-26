# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  include ImageAttachments

  after_deliver :log_forward_email

  helper :application, :issues

  def forward(issue_email:)
  def forward(issue_email:, user: Current.user)
    @issue_email = issue_email
    @user = user
    image_attachments issue: issue_email.issue if issue_email.send_photos?
    mail to: issue_email.to_email, bcc: issue_email.from_email, reply_to: issue_email.from_email
  end

  def in_process(to:, issue:)
    @issue = issue
    mail(to:, subject: default_i18n_subject(number: @issue.id))
  end

  def closed(to:, issue:)
    @issue = issue
    mail(to:, subject: default_i18n_subject(number: @issue.id))
  end

  def delegation(to:, issues:, auth_codes: [])
    @issues = issues
    @auth_codes = auth_codes
    mail to:
  end

  def inform_editorial_staff(to:, issues:, days:)
    @days = days
    @issues = issues
    mail(to:, subject: default_i18n_subject(title: Settings::Instance.name))
  end

  private

  def log_forward_email
    return unless Settings::Instance.log_issue_mailer_forward
    action = "#{t('issues.edit.new_issue_issue_email_title')} (#{@issue_email.to_email})"
    issue = @issue_email.issue
    issue.log_entries.create!(action:, issue_id: issue.id, subject_name: issue.to_s, user: Current.user)
  end
end
