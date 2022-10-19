# frozen_string_literal: true

class CreateCompletion < ActiveRecord::Migration[6.1]
  def change
    create_table :completion do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :author
      t.text :notice
      t.integer :status
      t.integer :prev_issue_status
      t.text :confirmation_hash
      t.timestamp :confirmed_at
      t.timestamp :closed_at
      t.timestamp :rejected_at

      t.timestamps
    end
  end
end
