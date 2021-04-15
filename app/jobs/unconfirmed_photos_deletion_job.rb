# frozen_string_literal: true

class UnconfirmedPhotosDeletionJob < ApplicationJob
  def perform
    unconfirmed_photos(Time.current - Jobs::Photo.deletion_deadline.hours).destroy_all
  end

  private

  def unconfirmed_photos(time)
    Photo.where(iat[:confirmed_at].eq(nil).and(iat[:created_at].lt(time)))
  end

  def iat
    Photo.arel_table
  end
end
