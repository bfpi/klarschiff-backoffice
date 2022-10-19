# frozen_string_literal: true

module QueryMethods
  extend ActiveSupport::Concern

  private

  def latest_attr_change(time, attr, comparison = :lt)
    LogEntry.select('DISTINCT ON ("issue_id") "issue_id"').where(
      log_entry_arel_table[:issue_id].not_eq(nil)
        .and(log_entry_arel_table[:attr].eq(attr).and(log_entry_arel_table[:created_at].send(comparison, time)))
    ).order(:issue_id, created_at: :desc)
  end

  def status_since_deadline(time, statuses)
    LogEntry.select('DISTINCT ON ("issue_id") "issue_id"').where(status_conds(time, statuses))
      .order(:issue_id, created_at: :desc)
  end

  def status_conds(time, statuses)
    log_entry_arel_table[:issue_id].not_eq(nil).and(log_entry_arel_table[:attr].eq('status'))
      .and(log_entry_arel_table[:new_value].in(statuses)).and(log_entry_arel_table[:created_at].gteq(time))
  end
end
