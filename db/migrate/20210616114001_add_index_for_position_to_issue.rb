# frozen_string_literal: true

class AddIndexForPositionToIssue < ActiveRecord::Migration[6.0]
  def change
    add_index :issue, :position, using: :gist
  end
end
