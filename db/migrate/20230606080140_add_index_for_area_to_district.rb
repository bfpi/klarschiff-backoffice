# frozen_string_literal: true

class AddIndexForAreaToDistrict < ActiveRecord::Migration[7.0]
  def change
    add_index :district, :area, using: :gist
  end
end
