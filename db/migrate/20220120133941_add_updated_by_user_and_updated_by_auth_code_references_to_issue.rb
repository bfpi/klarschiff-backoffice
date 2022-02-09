# frozen_string_literal: true

class AddUpdatedByUserAndUpdatedByAuthCodeReferencesToIssue < ActiveRecord::Migration[6.0]
  def up
    change_table :issue, bulk: true do |t|
      t.references :updated_by_user, foreign_key: { to_table: :user }
      t.references :updated_by_auth_code, foreign_key: { to_table: :auth_code }
    end

    # rubocop:disable Rails/SkipsModelValidations
    Issue.unscoped.find_in_batches.each do |issues|
      issues.each do |issue|
        le = last_entry(issue)
        issue.update_columns(updated_by_user_id: le.user_id, updated_by_auth_code_id: le.auth_code_id) if le
      end
    end
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    change_table :issue, bulk: true do |t|
      t.remove :updated_by_user_id
      t.remove :updated_by_auth_code_id
    end
  end

  private

  def last_entry(issue)
    LogEntry.where(table: 'issue', subject_id: issue)
      .where(LogEntry.arel_table[:user_id].not_eq(nil).or(LogEntry.arel_table[:auth_code_id].not_eq(nil)))
      .order(created_at: :desc).first
  end
end
