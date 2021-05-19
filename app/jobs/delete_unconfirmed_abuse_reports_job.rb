# frozen_string_literal: true

class DeleteUnconfirmedAbuseReportsJob < ApplicationJob
  def perform
    unconfirmed_abuse_reports(Time.current - JobSettings::Abuse.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_abuse_reports(time)
    AbuseReport.where(arat[:confirmed_at].eq(nil).and(arat[:created_at].lt(time)))
  end

  def arat
    AbuseReport.arel_table
  end
end
