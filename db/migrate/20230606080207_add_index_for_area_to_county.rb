# frozen_string_literal: true

class AddIndexForAreaToCounty < ActiveRecord::Migration[7.0]
  def change
    add_index :county, :area, using: :gist
  end
end
