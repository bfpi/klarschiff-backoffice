# frozen_string_literal: true

class DeleteUnconfirmedPhotosJob < ApplicationJob
  def perform
    unconfirmed_photos(Time.current - JobSettings::Photo.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_photos(time)
    Photo.where(pat[:confirmed_at].eq(nil).and(pat[:created_at].lt(time)))
  end

  def pat
    Photo.arel_table
  end
end