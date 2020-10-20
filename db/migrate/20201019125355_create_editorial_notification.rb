# frozen_string_literal: true

class CreateEditorialNotification < ActiveRecord::Migration[6.0]
  def change
    create_table :editorial_notification do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :level
      t.integer :repetition
      t.timestamp :notified_at

      t.timestamps
    end
  end
end
