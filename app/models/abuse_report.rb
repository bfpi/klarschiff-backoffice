# frozen_string_literal: true

class AbuseReport < ApplicationRecord
  include DateTimeAttributesWithBooleanAccessor
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true
  validates :confirmation_hash, presence: true, uniqueness: true

  before_validation :set_confirmation_hash, on: :create

  default_scope -> { order created_at: :desc }

  def to_s
    "#{I18n.l(created_at, format: :no_seconds)}#{I18n.t('statuses.abuse_report.open') unless resolved_at?}"
  end

  private

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end
end
