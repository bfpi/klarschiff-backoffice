# frozen_string_literal: true

class InformOnDelegatedIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    time = Time.current
    delegated_issues(time - JobSettings::Issue.delegation_deadline.hours)
      .group_by(&:delegation).each do |delegation, issues|
      recipients, auth_codes = recipients_and_auth_codes(delegation, issues)
      IssueMailer.delegation(
        to: recipients, issues: issues, auth_codes: auth_codes
      ).deliver_now
    end
  end

  private

  def recipients_and_auth_codes(group, issues)
    return [group.users.pluck(:email)] if group.users.exists?
    return [group.main_user.email] if group.main_user
    [group.email, issues.map { |issue| AuthCode.find_or_create_by(group: group, issue: issue) }]
  end

  def delegated_issues(time)
    Issue.where(iat[:delegation_id].not_eq(nil)).where(id: latest_attr_change(time, :delegation, :gteq))
  end
end
