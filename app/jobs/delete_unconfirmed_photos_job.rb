# frozen_string_literal: true

class DeleteUnconfirmedPhotosJob < ApplicationJob
  def perform
    unconfirmed_photos(JobSettings::Photo.deletion_deadline_days.days.ago).destroy_all
  end

  private

  def unconfirmed_photos(time)
    Photo.unscoped.where(photo_arel_table[:confirmed_at].eq(nil).and(photo_arel_table[:created_at].lt(time)))
  end
end
