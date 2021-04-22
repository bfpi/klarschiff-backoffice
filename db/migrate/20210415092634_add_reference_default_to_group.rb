# frozen_string_literal: true

class AddReferenceDefaultToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :group, :reference_default, :boolean, null: false, default: false
  end
end
