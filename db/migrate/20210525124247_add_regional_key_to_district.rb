# frozen_string_literal: true

class AddRegionalKeyToDistrict < ActiveRecord::Migration[6.0]
  def change
    add_column :district, :regional_key, :text
  end
end
