# frozen_string_literal: true

class NotificationOnClosedJob < ApplicationJob
  def perform
    issues_with_status_changes(Time.current - Jobs::Issue.status_change_days.days).find_each do |issue|
      IssueMailer.closed(to: issue.author, issue: issue).deliver_later
    end
  end

  private

  def issues_with_status_changes(time)
    Issue.joins(:all_log_entries).where(status: %w[closed not_solvable]).where(status_change_conds(time))
  end

  def status_change_conds(time)
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT("le"."created_at") FROM #{LogEntry.table_name} "le"
        WHERE "le"."issue_id" = #{Issue.table_name}."id" AND "le"."attr" = 'status' AND "le"."created_at" >= '#{time}'
          AND "le"."new_value" IN ('closed', 'not_solvable')
        GROUP BY "le"."created_at" ORDER BY "le"."created_at" DESC LIMIT 1
      ) = 1
    SQL
  end
end
