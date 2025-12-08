# frozen_string_literal: true

class FillIssueResponsibility < ActiveRecord::Migration[7.2]
  def up
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
    end
  end

  def down
    IssueResponsibility.delete_all
  end

  private

  def generate_issue_responsibility(issue_id, group_id, obj)
    IssueResponsibility.create issue_id: issue_id, group_id: group_id,
      created_at: obj.created_at, updated_at: Time.zone.now
  end
end
