# frozen_string_literal: true

class CreateAuthority < ActiveRecord::Migration[6.0]
  def change
    create_table :authority do |t|
      t.text :regional_key
      t.text :name
      t.multi_polygon :area
      t.references :county, null: false, foreign_key: true

      t.timestamps
    end
  end
end
