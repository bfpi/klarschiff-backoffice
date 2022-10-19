# frozen_string_literal: true

class DeleteUnconfirmedSupportersJob < ApplicationJob
  def perform
    unconfirmed_supporters(JobSettings::Support.deletion_deadline_days.days.ago).destroy_all
  end

  private

  def unconfirmed_supporters(time)
    Supporter.unscoped.where(supporter_arel_table[:confirmed_at].eq(nil)
      .and(supporter_arel_table[:created_at].lt(time)))
  end
end
