# frozen_string_literal: true

class CreateIssueResponsibility < ActiveRecord::Migration[7.2]
  def change
    create_table :issue_responsibility do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
