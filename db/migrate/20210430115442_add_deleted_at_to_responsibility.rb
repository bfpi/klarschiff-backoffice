# frozen_string_literal: true

class AddDeletedAtToResponsibility < ActiveRecord::Migration[6.0]
  def change
    add_column :responsibility, :deleted_at, :timestamp
  end
end
