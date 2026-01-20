# frozen_string_literal: true

class CreateIssueResponsibility < ActiveRecord::Migration[7.2]
  def up
    create_table :issue_responsibility do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.boolean :accepted, null: false, default: false

      t.timestamps
    end

    Issue.unscoped.find_each do |i|
      logs = i.log_entries.where(LogEntry.arel_table[:attr].eq('group')).order(:created_at).to_a
      if logs.none?
        generate_issue_responsibility(i.id, i.group_id, i)
        next
      end
      first = logs.shift
      generate_issue_responsibility(i.id, first.old_value_id, i)
      generate_issue_responsibility(i.id, first.new_value_id, first)

      logs.each do |l|
        generate_issue_responsibility(i.id, l.new_value_id, l)
      end

      i.log_entries.where(LogEntry.arel_table[:attr].eq('responsibility_accepted')).order(:created_at).to_a.each do |l|
        if l.new_value.downcase == I18n.t(true).downcase
          res = i.issue_responsibilities.where(IssueResponsibility.arel_table[:created_at].lteq(l.created_at)).last
          res&.update(accepted: true)
        end
      end
    end
  end

  def down
    drop_table :issue_responsibility
  end

  private

  def generate_issue_responsibility(issue_id, group_id, obj)
    IssueResponsibility.create issue_id: issue_id, group_id: group_id,
      created_at: obj.created_at, updated_at: Time.zone.now
  end
end
