# frozen_string_literal: true

class NotifyOnClosedIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    issues_with_status_changes(JobSettings::Issue.status_change_days.days.ago).find_each do |issue|
      IssueMailer.closed(to: issue.author, issue:).deliver_now
    end
  end

  private

  def issues_with_status_changes(time)
    Issue.where(status: %w[closed not_solvable duplicate]).where(
      id: status_since_deadline(time, [Issue.human_enum_name(:status, :closed),
                                       Issue.human_enum_name(:status, :not_solvable),
                                       Issue.human_enum_name(:status, :duplicate)])
    )
  end
end
