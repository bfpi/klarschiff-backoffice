# frozen_string_literal: true

class DeleteUnconfirmedIssuesJob < ApplicationJob
  def perform
    unconfirmed_issues(Time.current - JobSettings::Issue.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_issues(time)
    Issue.where(iat[:status].eq('pending').and(iat[:created_at].lt(time)))
  end

  def iat
    Issue.arel_table
  end
end
