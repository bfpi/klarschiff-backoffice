# frozen_string_literal: true

module DashboardsHelper
  def calc_percentage(count, total_count)
    "#{(count / total_count) * 100}%"
  end
end
