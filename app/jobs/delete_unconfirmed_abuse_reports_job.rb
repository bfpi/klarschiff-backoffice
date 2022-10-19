# frozen_string_literal: true

class DeleteUnconfirmedAbuseReportsJob < ApplicationJob
  def perform
    unconfirmed_abuse_reports(Time.current - JobSettings::Abuse.deletion_deadline_days.days).destroy_all
  end

  private

  def unconfirmed_abuse_reports(time)
    AbuseReport.unscoped.where(abuse_report_arel_table[:confirmed_at].eq(nil)
      .and(abuse_report_arel_table[:created_at].lt(time)))
  end
end
