# frozen_string_literal: true

class InformOnDelegatedIssuesJob < ApplicationJob
  def perform
    time = Time.current
    iss = delegated_issues(time - JobSettings::Issue.delegation_deadline.hours)
    iss.group_by(&:delegation).each do |delegation, issues|
      IssueMailer.delegation(to: delegation.user.pluck(:email), issues: issues).deliver_later
    end
  end

  private

  def delegated_issues(time)
    Issue.where(iat[:delegation_id].not_eq(nil)).where(delegation_conds(time))
  end

  def delegation_conds(time)
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT(le.created_at) FROM log_entry le
        WHERE le.issue_id = issue.id AND le.attr = 'delegation' AND le.new_value IS NOT NULL
          AND le.created_at >= '#{time}'
        GROUP BY le.created_at ORDER BY le.created_at DESC LIMIT 1
      ) = 1
    SQL
  end

  def iat
    Issue.arel_table
  end
end
