# frozen_string_literal: true

class AddTypeToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :group, :type, :string
  end
end
