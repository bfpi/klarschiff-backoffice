# frozen_string_literal: true

class Completion < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationWithHash
  include Logging

  attr_accessor :reject_with_status_reset

  enum status: { open: 0, closed: 1, rejected: 2 }, _prefix: true

  belongs_to :issue

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  validates :notice, presence: true, if: :status_rejected?
  validates :author, presence: true, on: :create
  validates :author, email: { if: -> { author.present? } }

  after_commit :close_issue, if: -> { confirmed_at && saved_change_to_confirmed_at? }
  after_commit :reject_completion, if: -> { status_rejected? && saved_change_to_status? }
  after_commit :set_closed_at_and_remove_author, if: -> { status_closed? && saved_change_to_status? }

  def to_s
    "#{I18n.l(created_at, format: :no_seconds)} (#{human_enum_name(:status)})"
  end

  private

  def set_closed_at_and_remove_author
    update(closed_at: Time.current, author: nil)
  end

  def close_issue
    return reject_with_notice if issue_closed?
    return update(prev_issue_status: completion.prev_issue_status) if open_completion.present?
    update(prev_issue_status: issue.status)
    issue.status_closed!
  end

  def open_completion
    issue.completions.where.not(id:).confirmed.status_open.first
  end

  def issue_closed?
    issue.status_closed? && issue.completions.exists?(status: 'closed')
  end

  def reject_with_notice
    update(status: 'rejected', notice: I18n.t('rejection_notice', number: issue.id))
  end

  def reject_completion
    issue.update(status: prev_issue_status) if reject_with_status_reset
    CompletionMailer.rejection(completion: self, to: author).deliver_later
    update(author: nil, rejected_at: Time.current)
  end
end
