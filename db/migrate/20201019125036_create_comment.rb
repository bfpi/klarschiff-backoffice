# frozen_string_literal: true

class CreateComment < ActiveRecord::Migration[6.0]
  def change
    create_table :comment do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :author
      t.text :message
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
