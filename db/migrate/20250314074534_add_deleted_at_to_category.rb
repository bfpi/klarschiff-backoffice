# frozen_string_literal: true

class AddDeletedAtToCategory < ActiveRecord::Migration[7.2]
  def change
    add_column :category, :deleted_at, :timestamp
  end
end
