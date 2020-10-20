# frozen_string_literal: true

class CreatePropertyOwner < ActiveRecord::Migration[6.0]
  def change
    create_table :property_owner do |t|
      t.text :parcel_key
      t.text :owner
      t.multi_polygon :area

      t.timestamps
    end
  end
end
