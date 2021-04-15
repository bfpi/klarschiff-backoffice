# frozen_string_literal: true

class InformEditorialStaffOnIssuesJob < ApplicationJob
  include SqlQuery

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
    %i[open_not_accepted in_process_no_status_note unsupported_ideas in_process].each do |method|
      next if (issues = send(method, time - Jobs::Issue.send("#{method}_days").days)).blank?
      @issues[method] = issues.to_a
    end
    %i[not_solvable_no_status_note not_open_not_accepted description_or_photo_not_released
       no_responsibility].each do |method|
      next if (issues = send(method)).blank?
      @issues[method] = issues.to_a
    end
  end

  def open_not_accepted(time)
    Issue.where(responsibility_accepted: false, status: 'received').where(latest_log_entry_sql(time, 'group'))
  end

  def in_process_no_status_note(time)
    Issue.where(status: 'in_process', status_note: nil).where(latest_log_entry_sql(time, 'status'))
  end

  def unsupported_ideas(time)
    Issue.unsupported.where(status: 'received').where(latest_log_entry_sql(time, 'group'))
  end

  def in_process(time)
    Issue.where(iat[:status].eq('in_process').and(iat[:created_at].lt(time)))
  end

  def not_solvable_no_status_note
    Issue.where(status: 'not_solvable', status_note: nil)
  end

  def not_open_not_accepted
    Issue.where(status: %w[reviewed in_process], responsibility_accepted: false)
  end

  def description_or_photo_not_released
    Issue.where(status: 'received', description_status: 'internal').where(photo_condition)
  end

  def photo_condition
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT("p"."id") FROM #{Photo.table_name} "p"
        WHERE #{Issue.table_name}."id" = "p"."issue_id" AND "p"."status" = 0
      ) = 0
    SQL
  end

  def no_responsibility
    Issue.where(
      iat[:archived_at].eq(nil).and(iat[:status].not_eq('pending')).and(iat[:group_id].eq(nil))
    )
  end

  def iat
    Issue.arel_table
  end
end
