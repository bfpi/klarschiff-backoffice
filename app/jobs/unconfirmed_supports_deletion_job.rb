# frozen_string_literal: true

class UnconfirmedSupportsDeletionJob < ApplicationJob
  def perform
    unconfirmed_supports(Time.current - Jobs::Support.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_supports(time)
    Supporter.where(iat[:confirmed_at].eq(nil).and(iat[:created_at].lt(time)))
  end

  def iat
    Supporter.arel_table
  end
end
