# frozen_string_literal: true

class AddUserAndAuthCodeReferencesToLogEntry < ActiveRecord::Migration[6.0]
  def up
    change_table :log_entry, bulk: true do |t|
      t.remove :user
      t.references :user, foreign_key: true
      t.references :auth_code, foreign_key: true
    end
  end

  def down
    change_table :log_entry, bulk: true do |t|
      t.remove :user_id
      t.remove :auth_code_id
      t.text :user
    end
  end
end
