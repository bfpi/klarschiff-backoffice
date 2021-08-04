# frozen_string_literal: true

class AddIndexesToIssue < ActiveRecord::Migration[6.0]
  def change
    change_table(:issue) do |t|
      t.index :archived_at
      t.index :responsibility_accepted
      t.index :status
    end
  end
end
