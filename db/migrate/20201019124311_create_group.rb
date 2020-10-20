# frozen_string_literal: true

class CreateGroup < ActiveRecord::Migration[6.0]
  def change
    create_table :group do |t|
      t.text :name
      t.text :short_name
      t.integer :kind
      t.text :email
      t.references :instance, null: false, foreign_key: true

      t.timestamps
    end
  end
end
