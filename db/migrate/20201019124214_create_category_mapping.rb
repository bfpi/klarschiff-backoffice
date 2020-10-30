# frozen_string_literal: true

class CreateCategoryMapping < ActiveRecord::Migration[6.0]
  def change
    create_table :category_mapping do |t|
      t.references :parent
      t.references :child

      t.timestamps
    end
  end
end
