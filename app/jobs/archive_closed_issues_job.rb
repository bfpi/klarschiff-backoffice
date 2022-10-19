# frozen_string_literal: true

class ArchiveClosedIssuesJob < ApplicationJob
  def perform
    time = Time.current
    issues_to_be_archived(time - JobSettings::Issue.archival_deadline_days.days).update(archived_at: time)
  end

  private

  def issues_to_be_archived(time)
    Issue.where(issue_arel_table[:status].in(Issue::CLOSED_STATUSES).and(issue_arel_table[:archived_at].eq(nil))
      .and(issue_arel_table[:updated_at].lt(time)))
  end
end
