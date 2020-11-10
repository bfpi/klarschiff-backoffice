# frozen_string_literal: true

class CreatePhoto < ActiveRecord::Migration[6.0]
  def change
    create_table :photo do |t|
      t.text :author
      t.references :issue, null: false, foreign_key: true
      t.integer :status
      t.text :confirmation_hash
      t.timestamp :confirmed_at

      t.timestamps
    end
  end
end
