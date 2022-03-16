# frozen_string_literal: true

class AddGroupResponsibilityRecipientToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :user, :group_responsibility_recipient, :boolean, null: false, default: false
  end
end
