# frozen_string_literal: true

class AddUserToComment < ActiveRecord::Migration[6.0]
  def change
    add_reference :comment, :user, null: true, foreign_key: true
  end
end
