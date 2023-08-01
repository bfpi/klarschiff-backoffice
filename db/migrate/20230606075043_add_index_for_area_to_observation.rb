# frozen_string_literal: true

class AddIndexForAreaToObservation < ActiveRecord::Migration[7.0]
  def change
    add_index :observation, :area, using: :gist
  end
end
