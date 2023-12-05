# frozen_string_literal: true

class InformEditorialStaffOnIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    time = Time.current
    EditorialNotification.find_each do |notification|
      next unless repetition_deadline_reached?(time, notification)
      @issues = {}
      @days = {}
      find_issues(time, notification.level, notification.user.group_ids)
      next if @issues.blank?
      IssueMailer.inform_editorial_staff(to: notification.user_email, issues: @issues, days: @days).deliver_now
      notification.touch :notified_at # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def repetition_deadline_reached?(time, notification)
    return true if notification.notified_at.blank?
    (time.to_date - notification.notified_at.to_date) >= notification.repetition
  end

  def find_issues(time, level, group_ids)
    %i[open_but_not_accepted in_work_without_status_note
       open_ideas_without_minimum_supporters created_not_in_work].each do |method|
      next if (issues = send(method, deadline(time, level, method), group_ids)).blank?
      @days[method] = notification_config(level)[:"days_#{method}"]
      @issues[method] = issues.to_a
    end
    optional_notifications(level, group_ids)
  end

  def optional_notifications(level, group_ids)
    %i[unsolvable_without_status_note reviewed_but_not_accepted without_editorial_approval].each do |method|
      next if (issues = send(method, group_ids)).blank? || notification_enabled?(level, method)
      @issues[method] = issues.to_a
    end
  end

  def deadline(time, level, method)
    time - notification_config(level)[:"days_#{method}"].days
  end

  def notification_enabled?(level, method)
    (conf = notification_config(level)) && conf[method]
  end

  def notification_config(level)
    EditorialSettings::Config.levels.find { |l| l[:level] == level }
  end

  def open_but_not_accepted(time, group_ids)
    Issue.not_archived.where(status: %w[reviewed in_process], responsibility_accepted: false)
      .where(group_id: group_ids).where(id: latest_attr_change(time, 'group'))
  end

  def in_work_without_status_note(time, group_ids)
    Issue.not_archived.status_in_process.where(
      status_note: nil, id: latest_attr_change(time, 'status'), group_id: group_ids
    )
  end

  def open_ideas_without_minimum_supporters(time, group_ids)
    open_issues.ideas_without_min_supporters.where(id: latest_attr_change(time, 'group'), group_id: group_ids)
  end

  def open_issues
    Issue.includes(ideas_includes).references(ideas_includes).left_joins(:supporters)
      .group(ideas_group_by).not_archived.status_open
  end

  def ideas_includes
    [:abuse_reports, :group, :delegation, :job, :photos, { category: %i[main_category sub_category] }]
  end

  def ideas_group_by
    [
      Category.arel_table[:id], 'delegation_issue.id', Group.arel_table[:id],
      Issue.arel_table[:id], Job.arel_table[:id], MainCategory.arel_table[:id],
      Photo.arel_table[:id], SubCategory.arel_table[:id], AbuseReport.arel_table[:id]
    ]
  end

  def created_not_in_work(time, group_ids)
    Issue.not_archived.status_in_process.where(issue_arel_table[:created_at].lt(time)).where(group_id: group_ids)
  end

  def unsolvable_without_status_note(group_ids)
    Issue.not_archived.status_not_solvable.where(status_note: nil, group_id: group_ids)
  end

  def reviewed_but_not_accepted(group_ids)
    Issue.not_archived.where(
      status: %w[reviewed in_process], responsibility_accepted: false, group_id: group_ids
    )
  end

  def without_editorial_approval(group_ids)
    Issue.not_archived.status_received.where(description_status: 'internal', group_id: group_ids)
      .reject { |is| is.photos.status_external.exists? }
  end
end
