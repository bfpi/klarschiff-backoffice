# frozen_string_literal: true

class DevideMainAndSubCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :main_category do |t|
      t.integer :kind
      t.text :name
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    create_table :sub_category do |t|
      t.text :name
      t.text :dms
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    reversible do |dir|
      change_table :category do |t|
        t.change_default :average_turnaround_time, 14
        dir.up do
          t.remove :kind, :name, :dms
          t.remove :deleted
          t.references :main_category
          t.references :sub_category
          t.index %i[main_category_id sub_category_id], unique: true
        end
        dir.down do
          t.text :kind
          t.text :name
          t.text :dms
          t.boolean :deleted, null: false, default: false
          t.remove_references :main_category
          t.remove_references :sub_category
        end
      end
    end
    drop_table :category_mapping do |t|
      t.references :parent
      t.references :child
      t.timestamps
    end
  end
end
