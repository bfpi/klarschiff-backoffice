# frozen_string_literal: true

class ResponsibilityMailer < ApplicationMailer
  helper :application

  def issue(issue, to:, auth_code:)
    @issue = issue
    @auth_code = auth_code
    mail to: to, interpolation: { subject: { number: @issue.id } }
  end

  def remind_group(group, to:, issues:)
    @issues = issues
    @days = JobSettings::Issue.group_responsibility_notification_deadline_days
    mail to: to, interpolation: { subject: { group: group.name } }
  end
end
