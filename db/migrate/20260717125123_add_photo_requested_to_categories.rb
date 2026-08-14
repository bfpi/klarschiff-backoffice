# frozen_string_literal: true

class AddPhotoRequestedToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :category, :photo_requested, :boolean, default: false, null: false
  end
end
