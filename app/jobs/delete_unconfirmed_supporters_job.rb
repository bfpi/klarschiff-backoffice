# frozen_string_literal: true

class DeleteUnconfirmedSupportersJob < ApplicationJob
  def perform
    unconfirmed_supporters(Time.current - JobSettings::Support.deletion_deadline_days.days).destroy_all
  end

  private

  def unconfirmed_supporters(time)
    Supporter.unscoped.where(sat[:confirmed_at].eq(nil).and(sat[:created_at].lt(time)))
  end

  def sat
    Supporter.arel_table
  end
end
