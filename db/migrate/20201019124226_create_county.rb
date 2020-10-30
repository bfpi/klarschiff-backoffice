# frozen_string_literal: true

class CreateCounty < ActiveRecord::Migration[6.0]
  def change
    create_table :county do |t|
      t.text :regional_key
      t.text :name
      t.multi_polygon :area

      t.timestamps
    end
  end
end
