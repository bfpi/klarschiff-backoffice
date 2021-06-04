# frozen_string_literal: true

class NotifyOnClosedIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    issues_with_status_changes(Time.current - JobSettings::Issue.status_change_days.days).find_each do |issue|
      IssueMailer.closed(to: issue.author, issue: issue).deliver_now
    end
  end

  private

  def issues_with_status_changes(time)
    Issue.where(status: %w[closed not_solvable duplicate]).where(
      id: status_since_deadline(time, %w[closed not_solvable duplicate])
    )
  end
end
