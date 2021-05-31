# frozen_string_literal: true

class InformOnDelegatedIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    time = Time.current
    delegated_issues(time - JobSettings::Issue.delegation_deadline.hours)
      .group_by(&:delegation).each do |delegation, issues|
      IssueMailer.delegation(
        to: recipients(delegation, issues), issues: issues, with_auth_code: delegation.users.none?
      ).deliver_later
    end
  end

  private

  def recipients(group, issues)
    return group.users.pluck(:email) if group.users.any?
    issues.find_each { |issue| AuthCode.find_or_create_by(group: group, issue: issue) }
    group.email
  end

  def delegated_issues(time)
    Issue.where(iat[:delegation_id].not_eq(nil)).where(id: latest_attr_change(time, :delegation, :gteq))
  end
end
