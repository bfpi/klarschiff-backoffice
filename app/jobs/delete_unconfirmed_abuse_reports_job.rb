# frozen_string_literal: true

class DeleteUnconfirmedAbuseReportsJob < ApplicationJob
  def perform
    unconfirmed_abuse_reports(Time.current - JobSettings::Abuse.deletion_deadline_days.days).destroy_all
  end

  private

  def unconfirmed_abuse_reports(time)
    AbuseReport.unscoped.where(arat[:confirmed_at].eq(nil).and(arat[:created_at].lt(time)))
  end

  def arat
    AbuseReport.arel_table
  end
end
