# frozen_string_literal: true

class CreateIssueDelegation < ActiveRecord::Migration[7.2]
  def up
    create_table :issue_delegation do |t|
      t.references :issue, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.boolean :rejected, null: false, default: false

      t.timestamps
    end

    Issue.unscoped.find_each do |i|
      logs = i.log_entries.where(arel_condition(false)).order(:created_at).to_a
      if logs.none?
        generate_issue_delegation(i.id, i.group_id, i)
      else
        first = logs.shift
        generate_issue_delegation(i.id, first.old_value_id, i)
        generate_issue_delegation(i.id, first.new_value_id, first)

        logs.each do |l|
          generate_issue_delegation(i.id, l.new_value_id, l)
        end
      end

      i.log_entries.where(arel_condition(true)).order(:created_at).to_a.each do |l|
        res = i.issue_delegations.where(IssueDelegation.arel_table[:created_at].lteq(l.created_at)).last
        res&.update(rejected: true)
      end
    end
  end

  def down
    drop_table :issue_delegation
  end

  private

  def arel_condition(empty)
    tmp = LogEntry.arel_table[:attr].eq('delegation')
    empty ? tmp.and(LogEntry.arel_table[:new_value].eq('')) : tmp.and(LogEntry.arel_table[:new_value].not_eq(''))
  end

  def generate_issue_delegation(issue_id, group_id, obj)
    IssueDelegation.create issue_id: issue_id, group_id: group_id,
      created_at: obj.created_at, updated_at: Time.zone.now
  end
end
