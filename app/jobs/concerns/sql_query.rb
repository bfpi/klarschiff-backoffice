# frozen_string_literal: true

module SqlQuery
  extend ActiveSupport::Concern

  private

  def latest_log_entry_sql(time, attr)
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT("le"."created_at") FROM #{LogEntry.table_name} "le"
        WHERE "le"."issue_id" = #{Issue.table_name}."id" AND "le"."attr" = '#{attr}' AND "le"."created_at" < '#{time}'
        GROUP BY "le"."created_at" ORDER BY "le"."created_at" DESC LIMIT 1
      ) = 1
    SQL
  end
end
