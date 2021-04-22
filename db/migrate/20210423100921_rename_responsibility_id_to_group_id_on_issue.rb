# frozen_string_literal: true

class RenameResponsibilityIdToGroupIdOnIssue < ActiveRecord::Migration[6.0]
  def change
    rename_column :issue, :responsibility_id, :group_id
  end
end
