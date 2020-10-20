# frozen_string_literal: true

class CreateSupporter < ActiveRecord::Migration[6.0]
  def change
    create_table :supporter do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :confirmation_hash
      t.timestamp :confirmed_at

      t.timestamps
    end
  end
end
