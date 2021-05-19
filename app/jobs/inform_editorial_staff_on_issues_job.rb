# frozen_string_literal: true

class InformEditorialStaffOnIssuesJob < ApplicationJob
  include QueryMethods

  def perform
    time = Time.current
    @issues = {}
    find_issues(time)
    return if @issues.blank?
    IssueMailer.inform_editorial_staff(
      to: EditorialNotification.all.map { |n| n.user.email }, issues: @issues
    ).deliver_later
  end

  private

  def find_issues(time)
    %i[open_not_accepted in_process_no_status_note ideas_without_min_supporters in_process].each do |method|
      next if (issues = send(method, time - JobSettings::Issue.send("#{method}_days").days)).blank?
      @issues[method] = issues.to_a
    end
    %i[not_solvable_no_status_note not_open_not_accepted description_and_photo_not_released
       no_responsibility].each do |method|
      next if (issues = send(method)).blank?
      @issues[method] = issues.to_a
    end
  end

  def open_not_accepted(time)
    Issue.not_archived.status_received.where(responsibility_accepted: false)
      .where(id: latest_attr_change(time, 'group'))
  end

  def in_process_no_status_note(time)
    Issue.not_archived.status_in_process.where(status_note: nil).where(id: latest_attr_change(time, 'status'))
  end

  def ideas_without_min_supporters(time)
    open_issues.ideas_without_min_supporters.where(id: latest_attr_change(time, 'group'))
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

  def in_process(time)
    Issue.not_archived.status_in_process.where(iat[:created_at].lt(time))
  end

  def not_solvable_no_status_note
    Issue.not_archived.status_not_solvable.where(status_note: nil)
  end

  def not_open_not_accepted
    Issue.not_archived.where(status: %w[reviewed in_process], responsibility_accepted: false)
  end

  def description_and_photo_not_released
    Issue.not_archived.status_received.where(description_status: 'internal')
      .reject { |is| is.photos.status_external.exists? }
  end

  def no_responsibility
    Issue.not_archived.where(
      iat[:archived_at].eq(nil).and(iat[:status].not_eq('pending')).and(iat[:group_id].eq(nil))
    )
  end
end
