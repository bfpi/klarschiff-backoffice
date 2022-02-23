# frozen_string_literal: true

class AddPasswordHistoryToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :user, bulk: true do |t|
      t.json :password_history
      t.datetime :password_updated_at
    end
  end
end
