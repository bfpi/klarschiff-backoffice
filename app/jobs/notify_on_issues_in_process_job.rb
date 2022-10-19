# frozen_string_literal: true

class NotifyOnIssuesInProcessJob < ApplicationJob
  include QueryMethods

  def perform
    issues_with_status_changes(JobSettings::Issue.status_change_days.days.ago).find_each do |issue|
      IssueMailer.in_process(to: issue.author, issue:).deliver_now
    end
  end

  private

  def issues_with_status_changes(time)
    Issue.status_in_process.where(id: status_since_deadline(time, [Issue.human_enum_name(:status, :in_process)]))
  end
end
