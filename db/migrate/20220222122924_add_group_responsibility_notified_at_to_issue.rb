# frozen_string_literal: true

class AddGroupResponsibilityNotifiedAtToIssue < ActiveRecord::Migration[6.1]
  def change
    add_column :issue, :group_responsibility_notified_at, :datetime
  end
end
