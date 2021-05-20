# frozen_string_literal: true

class Feedback < ApplicationRecord
  include AuthorBlacklist
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true

  default_scope -> { order created_at: :desc }

  before_create :set_recipient

  private

  def set_recipient
    recipient = identify_recipient
  end

  def identify_recipient
    user = issue.latest_editor
    return user.email if user&.group_feedback_recipient && issue.group.in?(user.groups)
    (group = issue.delegation || issue.group).main_user&.email || group.email
  end
end
