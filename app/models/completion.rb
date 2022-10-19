# frozen_string_literal: true

class Completion < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationWithHash
  include Logging

  attr_accessor :reject_with_status_reset

  self.omit_field_log += %w[prev_issue_status author]

  enum status: { open: 0, closed: 1, rejected: 2 }, _prefix: true
  enum prev_issue_status: Issue.statuses, _prefix: true

  belongs_to :issue

  default_scope -> { where.not(confirmed_at: nil).order(created_at: :desc) }

  validates :notice, presence: true, if: :status_rejected?
  validates :author, presence: true, on: :create
  validates :author, email: { if: -> { author.present? } }

  after_commit :close_issue, if: -> { confirmed_at && saved_change_to_confirmed_at? }
  after_commit :reject_completion, if: -> { status_rejected? && saved_change_to_status? }
  after_commit :set_closed_at_and_remove_author, if: -> { status_closed? && saved_change_to_status? }

  def to_s(show_created_at: false)
    str = ["##{id}"]
    str << I18n.l(created_at, format: :no_seconds) if show_created_at
    "#{str.join(' ')} (#{human_enum_name(:status)})"
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
    issue.completions.where.not(id:).status_open.first
  end

  def issue_closed?
    issue.status_closed? && issue.completions.exists?(status: :closed)
  end

  def reject_with_notice
    update(status: :rejected, notice: I18n.t('rejection_notice', number: issue.id))
  end

  def reject_completion
    issue.update(status: prev_issue_status) if reject_with_status_reset
    CompletionMailer.rejection(completion: self, to: author).deliver_later
    update(author: nil, rejected_at: Time.current)
  end
end
