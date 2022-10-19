# frozen_string_literal: true

class NotifyOnGroupAssignedResponsibilityJob < ApplicationJob
  include QueryMethods

  def perform
    unaccepted_issues.group_by(&:group).each do |group, issues|
      next if (recipients = group.responsibility_notification_recipients).blank?
      ResponsibilityMailer.remind_group(group, to: recipients, issues:).deliver_later
      Issue.where(id: issues).update_all group_responsibility_notified_at: Time.current # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def unaccepted_issues(deadline = JobSettings::Issue.group_responsibility_notification_deadline_days.days.ago)
    Issue.includes(:group).where(status: %w[received reviewed in_process], responsibility_accepted: false)
      .where.not(group_id: nil).where(issue_arel_table[:group_responsibility_notified_at].lt(deadline)
      .or(issue_arel_table[:group_responsibility_notified_at].eq(nil)))
  end
end
