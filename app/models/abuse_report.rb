# frozen_string_literal: true

class AbuseReport < ApplicationRecord
  include AuthorBlacklist
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

  private

  def send_confirmation
    ConfirmationMailer.abuse(to: author, issue_id: issue.id, confirmation_hash: confirmation_hash).deliver_later
  end
end
