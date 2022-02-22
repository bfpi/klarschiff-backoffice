# frozen_string_literal: true

class NotifyIssuesGroupJob < ApplicationJob
  include QueryMethods

  def perform
    unaccepted_issues.find_each do |issue|
      issue.send(:notify_group)
    end
  end

  private

  def unaccepted_issues
    Issue.where(status: %w[received reviewed in_process], responsibility_accepted: false)
      .where.not(group_id: nil).where(iat[:last_notification].lt(last_notification_deadline))
  end

  def last_notification_deadline
    Time.current - JobSettings::Issue.group_notification_days.days
  end
end
