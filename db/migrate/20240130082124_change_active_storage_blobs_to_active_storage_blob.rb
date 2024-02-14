# frozen_string_literal: true

class ChangeActiveStorageBlobsToActiveStorageBlob < ActiveRecord::Migration[7.1]
  def change
    rename_table :active_storage_blobs, :active_storage_blob
  end
end
