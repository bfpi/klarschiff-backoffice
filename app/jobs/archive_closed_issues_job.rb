# frozen_string_literal: true

class ArchiveClosedIssuesJob < ApplicationJob
  def perform
    time = Time.current
    issues_to_be_archived(time - JobSettings::Issue.archival_deadline_days.days).update(archived_at: time)
  end

  private

  def issues_to_be_archived(time)
    Issue.where(iat[:status].in(Issue::CLOSED_STATUSES).and(iat[:archived_at].eq(nil)).and(iat[:updated_at].lt(time)))
  end

  def iat
    Issue.arel_table
  end
end
