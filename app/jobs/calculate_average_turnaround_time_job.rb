# frozen_string_literal: true

class CalculateAverageTurnaroundTimeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Category.find_each do |category|
      next if (days = average_turnaround_days(category.id)).blank?
      category.update! average_turnaround_time: days
    end
  end

  private

  def average_turnaround_days(category_id) # rubocop:disable Metrics/MethodLength
    status = Issue.human_enum_name(:status, :in_process)
    LogEntry.connection.select_value <<~SQL.squish
      SELECT EXTRACT(DAY FROM AVG("diff"))::INTEGER
      FROM (
        SELECT DISTINCT ON ("le"."id") "le"."created_at" - "prev"."created_at" "diff"
        FROM #{LogEntry.quoted_table_name} "le"
          JOIN #{LogEntry.quoted_table_name} "prev" ON
            "prev"."issue_id" = "le"."issue_id" AND
            "prev"."created_at" < "le"."created_at" AND
            "prev"."table" = 'issue' AND
            "prev"."attr" = 'status' AND
            "prev"."new_value" = '#{status}'
        WHERE "le"."table" = 'issue' AND
          "le"."attr" = 'status' AND
          "le"."old_value" = '#{status}' AND
          "le"."issue_id" IN (SELECT "id" FROM #{Issue.quoted_table_name} WHERE "category_id" = #{category_id})
        ORDER BY "le".id, "prev"."created_at" DESC
      ) s
    SQL
  end
end
