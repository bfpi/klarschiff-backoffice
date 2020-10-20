# frozen_string_literal: true

class CreateCommunity < ActiveRecord::Migration[6.0]
  def change
    create_table :community do |t|
      t.text :regional_key
      t.text :name
      t.multi_polygon :area
      t.references :authority, null: false, foreign_key: true

      t.timestamps
    end
  end
end
