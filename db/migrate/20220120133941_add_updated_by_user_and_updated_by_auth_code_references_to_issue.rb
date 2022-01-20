# frozen_string_literal: true

class AddUpdatedByUserAndUpdatedByAuthCodeReferencesToIssue < ActiveRecord::Migration[6.0]
  def up
    change_table :issue, bulk: true do |t|
      t.references :updated_by_user, foreign_key: { to_table: :user }
      t.references :updated_by_auth_code, foreign_key: { to_table: :auth_code }
    end

    Issue.unscoped.each do |issue|
      le = last_entry(issue)
      issue.update(updated_by_user: le.user, updated_by_auth_code: le.auth_code) if le
    end
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
