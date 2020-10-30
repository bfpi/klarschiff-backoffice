# frozen_string_literal: true

class CreateLogEntry < ActiveRecord::Migration[6.0]
  def change
    create_table :log_entry do |t|
      t.text :table
      t.text :attr
      t.bigint :issue_id
      t.bigint :subject_id
      t.text :subject_name
      t.text :action
      t.text :user
      t.text :old_value
      t.text :new_value

      t.timestamps

      t.index %i[table subject_id]
    end
  end
end
