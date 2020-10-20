# frozen_string_literal: true

class CreateCategory < ActiveRecord::Migration[6.0]
  def change
    create_table :category do |t|
      t.integer :kind
      t.references :category
      t.text :name
      t.text :dms
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
