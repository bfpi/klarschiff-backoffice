# frozen_string_literal: true

class CreateIssue < ActiveRecord::Migration[6.0]
  def change
    create_table :issue do |t|
      t.st_point :position
      t.text :address
      t.timestamp :archived_at
      t.text :author
      t.text :description
      t.integer :description_status, null: false, default: Issue.description_statuses[:internal]
      t.timestamp :reviewed_at
      t.text :confirmation_hash
      t.integer :priority, null: false, default: Issue.priorities[:middle]
      t.integer :status
      t.text :status_note
      t.integer :kind
      t.references :category, null: false, foreign_key: true
      t.text :parcel
      t.text :property_owner
      t.boolean :photo_requested, null: false, default: false
      t.integer :trust_level
      t.date :expected_closure
      t.boolean :responsibility_accepted, null: false, default: false

      t.timestamps
    end
  end
end
