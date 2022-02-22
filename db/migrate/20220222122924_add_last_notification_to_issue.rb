# frozen_string_literal: true

class AddLastNotificationToIssue < ActiveRecord::Migration[6.1]
  def change
    add_column :issue, :last_notification, :datetime
  end
end
