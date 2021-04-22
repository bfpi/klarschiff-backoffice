# frozen_string_literal: true

class DropNotNullForMainUserOnGroup < ActiveRecord::Migration[6.0]
  def up
    change_column_null :group, :main_user_id, true
  end

  def down; end
end
