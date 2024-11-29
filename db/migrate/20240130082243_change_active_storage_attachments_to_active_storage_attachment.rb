# frozen_string_literal: true

class ChangeActiveStorageAttachmentsToActiveStorageAttachment < ActiveRecord::Migration[7.1]
  def change
    rename_table :active_storage_attachments, :active_storage_attachment
  end
end
