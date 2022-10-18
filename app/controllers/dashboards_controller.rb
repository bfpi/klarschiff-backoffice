# frozen_string_literal: true

class DashboardsController < ApplicationController
  include Issues

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
    @description_not_approved_issues = Issue.authorized.not_archived.description_not_approved.uniq
    @photos_not_approved_issues = Issue.authorized.not_archived.photos_not_approved.uniq
    @open_abuse_report_issues = Issue.authorized.open_abuse_reports.uniq
    @open_completion_issues = Issue.authorized.open_completions.uniq
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
end
