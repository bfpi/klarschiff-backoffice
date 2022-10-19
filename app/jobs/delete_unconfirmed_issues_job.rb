# frozen_string_literal: true

class DeleteUnconfirmedIssuesJob < ApplicationJob
  def perform
    unconfirmed_issues(JobSettings::Issue.deletion_deadline_days.days.ago).destroy_all
  end

  private

  def unconfirmed_issues(time)
    Issue.where(issue_arel_table[:status].eq('pending').and(issue_arel_table[:created_at].lt(time)))
  end
end
