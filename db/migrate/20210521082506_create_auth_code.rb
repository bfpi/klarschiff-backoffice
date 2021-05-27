# frozen_string_literal: true

class CreateAuthCode < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_code do |t|
      t.uuid :uuid
      t.references :issue, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
