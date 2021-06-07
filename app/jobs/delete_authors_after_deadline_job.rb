# frozen_string_literal: true

class DeleteAuthorsAfterDeadlineJob < ApplicationJob
  def perform
    Issue.where(
      deletion_conds(Time.current - JobSettings::Issue.author_deletion_deadline_days.days)
    ).find_each do |issue|
      remove_author(issue)
    end
  end

  private

  # rubocop:disable Rails/SkipsModelValidations
  def remove_author(issue)
    issue.update_all(author: nil)
    issue.abuse_reports.update_all(author: nil)
    issue.photos.update_all(author: nil)
    issue.feedbacks.update_all(author: nil)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def deletion_conds(time)
    iat[:archived_at].not_eq(nil).and(iat[:archived_at].lt(time))
  end

  def iat
    Issue.arel_table
  end
end
