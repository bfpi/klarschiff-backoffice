# frozen_string_literal: true

class DropPropertyOwner < ActiveRecord::Migration[6.0]
  def up
    drop_table :property_owner
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
