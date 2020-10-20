# frozen_string_literal: true

class CreateObservation < ActiveRecord::Migration[6.0]
  def change
    create_table :observation do |t|
      t.text :key
      t.text :category_ids
      t.multi_polygon :area

      t.timestamps
    end
  end
end
