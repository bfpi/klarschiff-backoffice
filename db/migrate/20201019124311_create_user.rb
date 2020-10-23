# frozen_string_literal: true

class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :user do |t|
      t.text :first_name
      t.text :last_name
      t.text :email
      t.text :login
      t.text :password_digest
      t.text :ldap
      t.boolean :group_feedback_recipient, null: false, default: false
      t.integer :role
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
