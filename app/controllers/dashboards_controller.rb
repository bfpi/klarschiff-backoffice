# frozen_string_literal: true

class DashboardsController < ApplicationController
  def show
    issues
    notices
    @notices_count = @received_not_accepted.count + @open_ideas.count + @not_approved_issues.count +
                     @in_process.count + @open_not_accepted.count
  end

  private

  def issues
    @latest_issues = Issue.not_archived.order(created_at: :desc).limit(10)
    @own_issues = own_issues
    @former_issues = former_issues
    @issues_count = { open: Issue.open.count, in_process: Issue.where(status: 'in_process').count,
                      closed: Issue.where(status: 'closed').count }
  end

  def notices
    @received_not_accepted = received_not_accepted
    @open_ideas = open_ideas(Time.current - 60.days)
    @not_approved_issues = Issue.not_archived.not_approved
    @in_process = in_process(Time.current - 30.days)
    @open_not_accepted = open_not_accepted(Time.current - 3.days)
  end

  def own_issues
    Issue.not_archived.joins(:all_log_entries).where(
      status: %w[pending received reviewed in_process not_solvable closed],
      log_entry: { attr: [nil] + %w[address status description kind] }
    ).where(LogEntry.arel_table[:created_at].gteq(Date.current - 7.days)).limit(10).distinct
  end

  def former_issues
    Issue.joins(:all_log_entries).not_archived.where(archived_at: nil)
      .where.not(group_id: Current.user.group_ids).where(changed_responsibilities).limit(10).distinct
  end

  def changed_responsibilities
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT("le"."created_at") FROM #{LogEntry.table_name} "le"
        WHERE "le"."issue_id" = "issue"."id" AND "le"."created_at" <= (
          SELECT "le2"."created_at" FROM #{LogEntry.table_name} "le2"
          WHERE "le2"."attr" = 'responsibility_accepted' AND "le2"."new_value" = 'ja' AND "le2"."issue_id" = "issue"."id"
          ORDER BY "le2"."created_at" ASC LIMIT 1
        )
        GROUP BY "le"."created_at" ORDER BY "le"."created_at" DESC LIMIT 1
      ) = 1
    SQL
  end

  def received_not_accepted
    Issue.not_archived.where(responsibility_accepted: false, status: :in_process)
  end

  def open_ideas(date)
    Issue.not_archived.open.unsupported.where(iat[:reviewed_at].not_eq(nil).and(iat[:reviewed_at].lteq(date)))
  end

  def in_process(date)
    Issue.not_archived.where(
      iat[:status].eq('in_process').and(iat[:status_note].eq(nil)).and(iat[:created_at].lteq(date))
    )
  end

  def open_not_accepted(date)
    Issue.not_archived.open.where(responsibility_accepted: false).where.not(group_id: nil)
      .where(responsibility_sql(date))
  end

  def responsibility_sql(date)
    Arel.sql(<<~SQL.squish)
      (
        SELECT COUNT("le"."created_at") FROM #{LogEntry.table_name} "le"
        WHERE "le"."attr" = 'group' AND "le"."issue_id" = "issue"."id" AND "le"."new_value" IS NOT NULL
          AND "le"."created_at" <= '#{date}'
        GROUP BY "le"."created_at" ORDER BY "le"."created_at" DESC LIMIT 1
      ) = 1
    SQL
  end

  def iat
    Issue.arel_table
  end
end
