# frozen_string_literal: true

class NotifyOnGroupAssignedResponsibilityJob < ApplicationJob
  include QueryMethods

  def perform
    unaccepted_issues.group_by(&:group).each do |group, issues|
      next if (recipients = group.responsibility_notification_recipients).blank?
      ResponsibilityMailer.remind_group(group, to: recipients, issues: issues).deliver_later
      Issue.where(id: issues).update_all group_responsibility_notified_at: Time.current # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def unaccepted_issues
    Issue.includes(:group).where(status: %w[received reviewed in_process], responsibility_accepted: false)
      .where.not(group_id: nil).where(iat[:group_responsibility_notified_at].lt(notification_deadline)
      .or(iat[:group_responsibility_notified_at].eq(nil)))
  end

  def notification_deadline
    Time.current - JobSettings::Issue.group_responsibility_notification_deadline_days.days
  end
end
