# frozen_string_literal: true

class CreateMailBlacklist < ActiveRecord::Migration[6.0]
  def change
    create_table :mail_blacklist do |t|
      t.text :pattern
      t.text :source
      t.text :reason

      t.timestamps
    end
  end
end
