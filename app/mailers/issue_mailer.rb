# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  include ImageAttachments

  helper :application, :issues

  def forward(issue_email:)
    @issue_email = issue_email
    image_attachments issue: issue_email.issue if issue_email.send_photos?
    mail to: issue_email.to_email, bcc: issue_email.from_email, reply_to: issue_email.from_email
  end

  def in_process(to:, issue:)
    @issue = issue
    mail(to:, interpolation: { subject: { number: @issue.id } })
  end

  def closed(to:, issue:)
    @issue = issue
    mail(to:, interpolation: { subject: { number: @issue.id } })
  end

  def delegation(to:, issues:, auth_codes: [])
    @issues = issues
    @auth_codes = auth_codes
    mail to:
  end

  def inform_editorial_staff(to:, issues:, days:)
    @days = days
    @issues = issues
    mail(to:, interpolation: { subject: { title: Settings::Instance.name } })
  end
end
