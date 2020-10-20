# frozen_string_literal: true

class CreateDistrict < ActiveRecord::Migration[6.0]
  def change
    create_table :district do |t|
      t.text :name
      t.multi_polygon :area
      t.references :community, null: false, foreign_key: true

      t.timestamps
    end
  end
end
