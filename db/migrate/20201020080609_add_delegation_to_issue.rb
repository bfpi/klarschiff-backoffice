# frozen_string_literal: true

class AddDelegationToIssue < ActiveRecord::Migration[6.0]
  def change
    add_reference :issue, :delegation, foreign_key: { to_table: :group }
  end
end
