# frozen_string_literal: true

class RemoveIssueFromJob < ActiveRecord::Migration[6.0]
  def up
    remove_reference :job, :issue
  end

  def down
    add_reference :job, :issue
  end
end
