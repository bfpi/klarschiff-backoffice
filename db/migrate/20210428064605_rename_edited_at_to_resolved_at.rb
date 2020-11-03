# frozen_string_literal: true

class RenameEditedAtToResolvedAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :abuse_report, :edited_at, :resolved_at
  end
end
