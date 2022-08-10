# frozen_string_literal: true

class ResponsibilityMailer < ApplicationMailer
  include ImageAttachments

  helper :application

  def issue(issue, to:, auth_code: nil)
    @issue = issue
    @issue_url = auth_code ? issues_url(auth_code: auth_code.uuid) : edit_issue_url(issue)
    mail to:, interpolation: { subject: { number: @issue.id } }
  end

  def default_group(issue, to:, auth_code: nil)
    @issue = issue
    @auth_code = auth_code
    image_attachments(issue: @issue)
    mail(to:, interpolation: { subject: { number: @issue.id } })
  end

  def remind_group(group, to:, issues:)
    @issues = issues
    @days = JobSettings::Issue.group_responsibility_notification_deadline_days
    mail to:, interpolation: { subject: { group: group.short_name } }
  end
end
