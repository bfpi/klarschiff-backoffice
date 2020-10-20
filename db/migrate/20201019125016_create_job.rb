# frozen_string_literal: true

class CreateJob < ActiveRecord::Migration[6.0]
  def change
    create_table :job do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :status
      t.integer :order
      t.date :date

      t.timestamps
    end
  end
end
