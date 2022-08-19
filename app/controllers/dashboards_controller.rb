# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action { check_auth :view_dashboard }
  before_action :collect_issues, :collect_notices, :calculate_issues_counts

  def show
    @notices_count = [@in_process_not_accepted, @open_ideas_without_min_supporters, @description_not_approved_issues,
                      @photos_not_approved_issues, @in_process, @open_not_accepted].sum(&:count)
  end

  private

  def collect_issues
    @latest_issues = latest_issues
    @own_issues = own_issues
    @former_issues = former_issues(Current.user.groups)
    @description_not_approved_issues = Issue.authorized.not_archived.description_not_approved
    @photos_not_approved_issues = Issue.authorized.not_archived.photos_not_approved
    @open_abuse_report_issues = Issue.authorized.open_abuse_reports
  end

  def calculate_issues_counts
    base = Issue.not_archived.authorized
    @issues_count = { open: base.status_open.not_status_in_process.count, in_process: base.status_in_process.count,
                      closed: base.status_closed.count }
  end

  def collect_notices
    @in_process_not_accepted = in_process_not_accepted
    @open_ideas_without_min_supporters = open_ideas_without_min_supporters(60.days.ago)
    @in_process = in_process(30.days.ago)
    @open_not_accepted = open_not_accepted(3.days.ago)
  end

  def latest_issues
    Issue.authorized.includes({ category: :main_category }).not_archived
      .where(status: %w[received reviewed in_process not_solvable closed])
      .order(iat[:priority].desc, iat[:updated_at].desc, iat[:id].desc).limit(10)
  end

  def own_issues
    Issue.authorized.not_archived.includes(category: :main_category).joins(:all_log_entries).where(
      status: %w[received reviewed in_process not_solvable closed],
      log_entry: { attr: [nil] + %w[address status description kind] }
    ).where(LogEntry.arel_table[:created_at].gteq(Date.current - 7.days))
      .order(iat[:updated_at].desc, iat[:id].desc).limit(10).distinct
  end

  def former_issues(groups)
    return [] if groups.blank?
    Issue.not_archived.includes(category: :main_category).where(changed_responsibilities(groups.ids)).limit 10
  end

  def changed_responsibilities(group_ids)
    ids = group_ids.join(', ')
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
        WHERE "attr" = 'group' AND "new_value_id" IN (#{ids})
          AND "le"."issue_id" IS NOT NULL AND "le"."issue_id" NOT IN (
            SELECT "id" FROM #{Issue.quoted_table_name} WHERE "group_id" IN (#{ids})))
    SQL
  end

  def in_process_not_accepted
    Issue.authorized.not_archived.where(status: %w[in_process not_solvable duplicate closed])
      .where(responsibility_accepted: false).order(id: :asc)
  end

  def open_ideas_without_min_supporters(date)
    open_issues.ideas_without_min_supporters
      .where(iat[:reviewed_at].not_eq(nil).and(iat[:reviewed_at].lteq(date))).order(id: :asc).to_a
  end

  def open_issues
    Issue.authorized.includes(includes).references(includes).left_joins(:supporters).group(group_by)
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
    Issue.authorized.not_archived.status_in_process.where(
      iat[:status_note].eq(nil).and(iat[:created_at].lteq(date))
    ).order(id: :asc)
  end

  def open_not_accepted(date)
    Issue.authorized.not_archived.status_open.where(responsibility_accepted: false).where.not(group_id: nil)
      .where(id: responsibility_entries(date)).order(id: :asc)
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
