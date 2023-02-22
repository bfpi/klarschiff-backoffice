# frozen_string_literal: true

class AddUuidToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :user, :uuid, :uuid
  end
end
