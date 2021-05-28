# frozen_string_literal: true

class InformOnDelegatedIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    time = Time.current
    iss = delegated_issues(time - JobSettings::Issue.delegation_deadline.hours)
    iss.group_by(&:delegation).each do |delegation, issues|
      IssueMailer.delegation(to: delegation.users.pluck(:email), issues: issues).deliver_later
    end
  end

  private

  def delegated_issues(time)
    Issue.where(iat[:delegation_id].not_eq(nil)).where(id: latest_attr_change(time, :delegation, :gteq))
  end
end
