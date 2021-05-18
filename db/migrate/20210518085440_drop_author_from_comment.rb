# frozen_string_literal: true

class DropAuthorFromComment < ActiveRecord::Migration[6.0]
  def change
    remove_column :comment, :author, :text, if_exists: true
  end
end
