# frozen_string_literal: true

class DropCommunityTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :community
  end

  def down
    create_table :community do |t|
      t.text :regional_key
      t.text :name
      t.multi_polygon :area, srid: 4326
      t.references :authority, null: false, foreign_key: true

      t.timestamps
    end
  end
end
