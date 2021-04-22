# frozen_string_literal: true

class CreateResponsibility < ActiveRecord::Migration[6.0]
  def change
    create_table :responsibility do |t|
      t.references :category, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
