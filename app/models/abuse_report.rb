# frozen_string_literal: true

class AbuseReport < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationWithHash
  include DateTimeAttributesWithBooleanAccessor
  include Logging

  belongs_to :issue

  validates :message, presence: true

  default_scope -> { where.not(confirmed_at: nil).order(created_at: :desc) }

  def to_s
    "#{I18n.l(created_at, format: :no_seconds)}#{I18n.t('statuses.abuse_report.open') unless resolved_at?}"
  end
end
