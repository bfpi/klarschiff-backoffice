# frozen_string_literal: true

class CreateFeedback < ActiveRecord::Migration[6.0]
  def change
    create_table :feedback do |t|
      t.references :issue, null: false, foreign_key: true
      t.text :message
      t.text :author
      t.text :recipient

      t.timestamps
    end
  end
end
