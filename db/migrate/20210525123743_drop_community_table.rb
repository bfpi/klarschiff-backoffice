# frozen_string_literal: true

class DropCommunityTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :community
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
