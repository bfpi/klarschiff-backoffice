# frozen_string_literal: true

module DashboardsHelper
  def calc_percentage(count, total_count)
    "#{(count.to_f / total_count.to_f) * 100}%"
  end
end