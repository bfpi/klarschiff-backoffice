# frozen_string_literal: true

class AbuseReport < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationCallbacks
  include ConfirmationWithHash
  include DateTimeAttributesWithBooleanAccessor
  include Logging

  belongs_to :issue

  validates :message, presence: true

  default_scope -> { order created_at: :desc }

  after_create :send_confirmation

  def to_s
    "#{I18n.l(created_at, format: :no_seconds)}#{I18n.t('statuses.abuse_report.open') unless resolved_at?}"
  end
end
