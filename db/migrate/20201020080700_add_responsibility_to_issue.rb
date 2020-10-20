# frozen_string_literal: true

class AddResponsibilityToIssue < ActiveRecord::Migration[6.0]
  def change
    add_reference :issue, :responsibility, foreign_key: { to_table: :group }
  end
end
