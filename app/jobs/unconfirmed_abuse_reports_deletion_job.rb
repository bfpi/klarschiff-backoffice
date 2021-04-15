# frozen_string_literal: true

class UnconfirmedAbuseReportsDeletionJob < ApplicationJob
  def perform
    unconfirmed_abuse_reports(Time.current - Jobs::Abuse.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_abuse_reports(time)
    AbuseReport.where(iat[:confirmed_at].eq(nil).and(iat[:created_at].lt(time)))
  end

  def iat
    AbuseReport.arel_table
  end
end
