# frozen_string_literal: true

class AddAttributesToLogEntry < ActiveRecord::Migration[6.1]
  def change
    change_table :log_entry, bulk: true do |t|
      t.bigint :old_value_id
      t.bigint :new_value_id, index: true
    end
  end
end
