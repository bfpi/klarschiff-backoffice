# frozen_string_literal: true

class AddAuthorityToDistrict < ActiveRecord::Migration[6.0]
  def change
    add_reference :district, :authority, null: false, foreign_key: true, default: 1
  end
end
