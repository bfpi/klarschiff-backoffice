# frozen_string_literal: true

class DropKindFromIssue < ActiveRecord::Migration[6.0]
  def change
    remove_column :issue, :kind, :integer
  end
end
