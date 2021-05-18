# frozen_string_literal: true

class DeleteUnconfirmedSupportersJob < ApplicationJob
  def perform
    unconfirmed_supporters(Time.current - Jobs::Support.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_supporters(time)
    Supporter.where(sat[:confirmed_at].eq(nil).and(sat[:created_at].lt(time)))
  end

  def sat
    Supporter.arel_table
  end
end
