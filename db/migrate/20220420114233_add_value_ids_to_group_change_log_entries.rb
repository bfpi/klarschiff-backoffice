# frozen_string_literal: true

class AddValueIdsToGroupChangeLogEntries < ActiveRecord::Migration[6.1]
  def up
    LogEntry.where(table: 'issue', attr: 'group').find_each do |entry|
      groups = Group.regional(lat: entry.issue.position.y, lon: entry.issue.position.x)
      add_group_ids!(entry, groups)
    end
  end

  def down; end

  private

  def add_group_ids!(entry, groups)
    old_group = find_group(entry.old_value, groups) 
    new_group = find_group(entry.new_value, groups) 
    entry.update!(old_value_id: old_group&.id, new_value_id: new_group&.id)
    error_logs(entry, old_group, new_group)
  end

  def error_logs(entry, old_group, new_group)
    error_message(entry.old_value, entry.id) if entry.old_value.present? && old_group.blank?
    error_message(entry.new_value, entry.id) if entry.new_value.present? && new_group.blank?
  end

  def error_message(value, id)
    Rails.logger.error "LogEntry ##{id}: Gruppe \"#{value}\" konnte nicht gefunden werden"
  end

  def find_group(value, groups)
    return if value.blank?
    group = Group.find_by(gat[:short_name].eq(value).or(gat[:name].eq(value)))
    return group if group
    value = cut_group_name(value)
    Group.find_by(gat[:short_name].eq(value).or(gat[:name].eq(value)))
  end

  def cut_group_name(name)
    name.remove(/\([^\(\)]+\)$/).strip
  end

  def gat
    Group.arel_table
  end
end
