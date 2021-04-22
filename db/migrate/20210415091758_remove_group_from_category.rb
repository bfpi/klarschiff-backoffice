# frozen_string_literal: true

class RemoveGroupFromCategory < ActiveRecord::Migration[6.0]
  def up
    remove_reference :category, :group
  end

  def down
    add_reference :category, :group
  end
end
