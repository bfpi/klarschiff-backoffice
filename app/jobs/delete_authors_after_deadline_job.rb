# frozen_string_literal: true

class DeleteAuthorsAfterDeadlineJob < ApplicationJob
  def perform
    Issue.where(deletion_conds(JobSettings::Issue.author_deletion_deadline_days.days.ago)).find_each do |issue|
      remove_author(issue)
    end
  end

  private

  def remove_author(issue)
    issue.update(author: JobSettings::Issue.author_deletion_replacement)
    # rubocop:disable Rails/SkipsModelValidations
    issue.abuse_reports.update_all(author: JobSettings::Issue.author_deletion_replacement)
    issue.photos.update_all(author: JobSettings::Issue.author_deletion_replacement)
    issue.feedbacks.update_all(author: JobSettings::Issue.author_deletion_replacement)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def deletion_conds(time)
    issue_arel_table[:author].not_eq(JobSettings::Issue.author_deletion_replacement)
      .and(issue_arel_table[:archived_at].lt(time))
  end
end
