# frozen_string_literal: true

class AddJobToIssue < ActiveRecord::Migration[6.0]
  def change
    add_reference :issue, :job
  end
end
