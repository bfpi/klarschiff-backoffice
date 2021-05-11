# frozen_string_literal: true

class AddIndicesForAttrAndIssueIdOnLogEntry < ActiveRecord::Migration[6.0]
  def change
    change_table :log_entry, bulk: true do |t|
      t.index :issue_id
      t.index :attr
    end
  end
end
