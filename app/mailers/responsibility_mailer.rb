# frozen_string_literal: true

class ResponsibilityMailer < ApplicationMailer
  helper :application

  def issue(issue, to:, auth_code: nil)
    @issue = issue
    @issue_url = auth_code ? issues_url(auth_code: auth_code.uuid) : edit_issue_url(issue)
    mail to: to, interpolation: { subject: { number: @issue.id } }
  end

  def remind_group(group, to:, issues:)
    @issues = issues
    @days = JobSettings::Issue.group_responsibility_notification_deadline_days
    mail to: to, interpolation: { subject: { group: group.short_name } }
  end
end
