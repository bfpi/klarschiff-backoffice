# frozen_string_literal: true

class DropCommunityFromDistrict < ActiveRecord::Migration[6.0]
  def change
    remove_reference :district, :community, null: false, foreign_key: true
  end
end
