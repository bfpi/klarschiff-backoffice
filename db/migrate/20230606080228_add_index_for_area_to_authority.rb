# frozen_string_literal: true

class AddIndexForAreaToAuthority < ActiveRecord::Migration[7.0]
  def change
    add_index :authority, :area, using: :gist
  end
end
