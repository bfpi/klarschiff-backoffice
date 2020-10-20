# frozen_string_literal: true

class CreateInstance < ActiveRecord::Migration[6.0]
  def change
    create_table :instance do |t|
      t.text :name
      t.text :url
      t.multi_polygon :area

      t.timestamps
    end
  end
end
