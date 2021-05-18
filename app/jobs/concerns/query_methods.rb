# frozen_string_literal: true

module QueryMethods
  extend ActiveSupport::Concern

  private

  def latest_attr_change(time, attr)
    LogEntry.select('DISTINCT ON ("issue_id") "issue_id"').where(
      leat[:issue_id].not_eq(nil).and(leat[:attr].eq(attr).and(leat[:created_at].lt(time))))
    ).order(:issue_id, created_at: :desc)
  end

  def status_since_deadline(time, statuses)
    LogEntry.select('DISTINCT ON ("issue_id") "issue_id"').where(
      leat[:issue_id].not_eq(nil).and(leat[:attr].eq('status').and(leat[:new_value].in(statuses)
      .and(leat[:created_at].lt(time))))
    ).order(:issue_id, created_at: :desc)
  end

  def iat
    Issue.arel_table
  end

  def leat
    LogEntry.arel_table
  end
end
