# frozen_string_literal: true

class CalculateAverageTurnaroundTimeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Category.all.each do |category|
      next if (times = category_times(category)).blank?
      category.average_turnaround_time = Time.at(times.sum / times.count).utc.day - 1
      category.save
    end
  end

  private

  def category_times(category)
    LogEntry.where(table: :issue, attr: :status, old_value: :in_process,
                   issue: category.issues).map { |log_entry| calculate_turnaround_time(log_entry) }.flatten
  end

  def calculate_turnaround_time(log_entry)
    log_entry.issue.all_log_entries.where(table: :issue, attr: :status, new_value: :in_process)
      .where('created_at < ?', log_entry.created_at)
      .order(created_at: :desc).limit(1).map { |tmp| (log_entry.created_at - tmp.created_at) }
  end
end
