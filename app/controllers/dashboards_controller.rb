# frozen_string_literal: true

class DashboardsController < ApplicationController
  def show
    check_auth(:view_dashboard)
    issues
    notices
    @notices_count = @in_process_not_accepted.count + @open_ideas_without_min_supporters.count +
                     @not_approved_issues.count + @in_process.count + @open_not_accepted.count
  end

  private

  def issues
    @latest_issues = latest_issues
    @own_issues = own_issues
    @former_issues = former_issues(Current.user.groups)
    @issues_count = { open: Issue.status_open.count, in_process: Issue.status_in_process.count,
                      closed: Issue.status_closed.count }
  end

  def notices
    @in_process_not_accepted = in_process_not_accepted
    @open_ideas_without_min_supporters = open_ideas_without_min_supporters(Time.current - 60.days)
    @not_approved_issues = Issue.not_archived.not_approved
    @in_process = in_process(Time.current - 30.days)
    @open_not_accepted = open_not_accepted(Time.current - 3.days)
  end

  def latest_issues
    Issue.includes({ category: :main_category }).not_archived
      .where(status: %w[received reviewed in_process not_solvable closed])
      .order(iat[:priority].desc, iat[:created_at].desc, iat[:id].desc).limit(10)
  end

  def own_issues
    Issue.not_archived.includes(category: :main_category).joins(:all_log_entries).where(
      status: %w[pending received reviewed in_process not_solvable closed],
      log_entry: { attr: [nil] + %w[address status description kind] }
    ).where(LogEntry.arel_table[:created_at].gteq(Date.current - 7.days)).limit(10).distinct
  end

  def former_issues(groups)
    return [] if groups.blank?
    group_names = groups.map { |g| "'#{g}'" }.join(', ')
    group_ids = groups.ids.join(', ')
    Issue.not_archived.includes(category: :main_category).where(
      changed_responsibilities(group_names, group_ids)
    ).limit(10)
  end

  def changed_responsibilities(group_names, group_ids)
    Arel.sql(<<~SQL.squish)
      #{Issue.quoted_table_name}."id" IN (SELECT DISTINCT "le"."issue_id" FROM #{LogEntry.quoted_table_name} "le"
        INNER JOIN (
          SELECT "issue_id", "created_at" FROM #{LogEntry.quoted_table_name}
            WHERE "attr" = 'responsibility_accepted' AND LOWER("new_value") = '#{I18n.t(true).downcase}'
        ) "le2" ON "le"."issue_id" = "le2"."issue_id" AND "le2"."created_at" >= "le"."created_at" AND (
          SELECT COUNT("id") FROM #{LogEntry.quoted_table_name} "le3"
           WHERE "le3"."issue_id" = "le"."issue_id" AND "le3"."attr" = 'group'
           AND "le3"."created_at" > "le"."created_at" AND "le3"."created_at" <= "le2"."created_at"
        ) = 0
        WHERE "attr" = 'group' AND "new_value" IN (#{group_names})
          AND "le"."issue_id" IS NOT NULL AND "le"."issue_id" NOT IN (
            SELECT "id" FROM #{Issue.quoted_table_name} WHERE "group_id" IN (#{group_ids})))
    SQL
  end

  def in_process_not_accepted
    Issue.not_archived.status_in_process.where(responsibility_accepted: false)
  end

  def open_ideas_without_min_supporters(date)
    open_issues.ideas_without_min_supporters
      .where(iat[:reviewed_at].not_eq(nil).and(iat[:reviewed_at].lteq(date))).to_a
  end

  def open_issues
    Issue.includes(includes).references(includes).left_joins(:supporters).group(group_by)
      .not_archived.status_open
  end

  def includes
    [:abuse_reports, :group, :delegation, :job, :photos, { category: %i[main_category sub_category] }]
  end

  def group_by
    [
      Category.arel_table[:id], 'delegation_issue.id', Group.arel_table[:id],
      Issue.arel_table[:id], Job.arel_table[:id], MainCategory.arel_table[:id],
      Photo.arel_table[:id], SubCategory.arel_table[:id], AbuseReport.arel_table[:id]
    ]
  end

  def in_process(date)
    Issue.not_archived.status_in_process.where(
      iat[:status_note].eq(nil).and(iat[:created_at].lteq(date))
    )
  end

  def open_not_accepted(date)
    Issue.not_archived.status_open.where(responsibility_accepted: false).where.not(group_id: nil)
      .where(id: responsibility_entries(date))
  end

  def responsibility_entries(date)
    LogEntry.select('DISTINCT ON ("issue_id") "issue_id"').where(
      leat[:issue_id].not_eq(nil).and(leat[:attr].eq('group')).and(leat[:created_at].lteq(date))
    ).order(:issue_id, created_at: :desc)
  end

  def leat
    LogEntry.arel_table
  end

  def iat
    Issue.arel_table
  end
end
