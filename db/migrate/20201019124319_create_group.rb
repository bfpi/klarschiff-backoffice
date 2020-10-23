# frozen_string_literal: true

class CreateGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :group do |t|
      t.text :name
      t.text :short_name
      t.integer :kind
      t.text :email
      t.references :user, null: false, foreign_key: true
      t.references :instance, null: false, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
