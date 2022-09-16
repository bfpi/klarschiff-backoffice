# frozen_string_literal: true

class Completion < ApplicationRecord
  include AuthorBlacklist
  include ConfirmationWithHash
  include Logging

  attr_accessor :reject_with_status_reset

  enum status: { open: 0, closed: 1, rejected: 2 }, _prefix: true

  belongs_to :issue

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  after_commit :close_issue, if: -> { confirmed_at && saved_change_to_confirmed_at? }
  after_commit :reset_issue_status, if: -> { status_rejected? && saved_change_to_status? && reject_with_status_reset }

  private

  def close_issue
    if (completion = issue.completions.confirmed.status_open.first).present?
      update(prev_issue_status: completion.prev_issue_status)
    else
      return if issue.status_closed?
      update(prev_issue_status: issue.status)
      issue.status_closed!
    end
  end

  def reset_issue_status
    issue.update(status: prev_issue_status)
  end
end
