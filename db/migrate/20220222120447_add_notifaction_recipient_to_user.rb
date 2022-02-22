# frozen_string_literal: true

class AddNotifactionRecipientToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :user, :notification_recipient, :boolean, default: false
  end
end
