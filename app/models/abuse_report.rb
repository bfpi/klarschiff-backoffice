# frozen_string_literal: true

class AbuseReport < ApplicationRecord
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true
  validates :confirmation_hash, presence: true, uniqueness: true

  before_validation :set_confirmation_hash, on: :create

  private

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end
end
