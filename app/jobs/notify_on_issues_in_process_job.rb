# frozen_string_literal: true

class NotifyOnIssuesInProcessJob < ApplicationJob
  include QueryMethods

  def perform
    issues_with_status_changes(Time.current - JobSettings::Issue.status_change_days.days).find_each do |issue|
      IssueMailer.in_process(to: issue.author, issue: issue).deliver_now
    end
  end

  private

  def issues_with_status_changes(time)
    Issue.status_in_process.where(id: status_since_deadline(time, %w[in_process]))
  end
end
