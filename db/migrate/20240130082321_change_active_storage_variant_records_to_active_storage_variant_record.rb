# frozen_string_literal: true

class ChangeActiveStorageVariantRecordsToActiveStorageVariantRecord < ActiveRecord::Migration[7.1]
  def change
    rename_table :active_storage_variant_records, :active_storage_variant_record
  end
end
