# frozen_string_literal: true

class CreateAbuseReport < ActiveRecord::Migration[6.0]
  def change
    create_table :abuse_report do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :message
      t.text :author
      t.text :confirmation_hash
      t.timestamp :confirmed_at
      t.timestamp :edited_at

      t.timestamps
    end
  end
end
