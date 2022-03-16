# frozen_string_literal: true

class NotifyOnGroupAssignedResponsibilityJob < ApplicationJob
  include QueryMethods

  def perform
    unaccepted_issues.find_each do |issue|
      issue.send(:notify_group)
    end
  end

  private

  def unaccepted_issues
    Issue.where(status: %w[received reviewed in_process], responsibility_accepted: false)
      .where.not(group_id: nil).where(iat[:group_responsibility_notified_at].lt(notification_deadline))
  end

  def notification_deadline
    Time.current - JobSettings::Issue.group_responsibility_notification_deadline_days.days
  end
end
