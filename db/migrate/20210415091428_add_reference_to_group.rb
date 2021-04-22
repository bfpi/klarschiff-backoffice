# frozen_string_literal: true

class AddReferenceToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :group, :reference_id, :integer, null: true, index: true
  end
end
