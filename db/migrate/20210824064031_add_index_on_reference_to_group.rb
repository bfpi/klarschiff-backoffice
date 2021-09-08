# frozen_string_literal: true

class AddIndexOnReferenceToGroup < ActiveRecord::Migration[6.1]
  def change
    add_index :group, :reference_id
  end
end
