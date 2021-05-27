# frozen_string_literal: true

class Feedback < ApplicationRecord
  include AuthorBlacklist
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true

  before_create :set_recipient
  after_create :notify

  default_scope -> { order created_at: :desc }

  def to_s
    "##{id}"
  end

  private

  def set_recipient
    self.recipient = identify_recipients
  end

  def identify_recipients
    group = issue.delegation || issue.group
    entry = issue.latest_entry
    return identify_recipients_from_user(entry.user, group) if entry&.user
    return identify_recipients_from_group(entry.auth_code.group) if entry&.auth_code
    identify_recipients_from_group(group)
  end

  def identify_recipients_from_user(user, group)
    return user.email if user.group_feedback_recipient && group.in?(user.groups)
    users = group.users.where(group_feedback_recipient: true)
    return users.pluck(:email).join(', ') if users.any?
    identify_recipients_from_group(group)
  end

  def identify_recipients_from_group(group)
    group.main_user&.email || group.email
  end

  def notify
    return notify_responsible_group if recipient.blank?
    recipient.split(', ').each do |email|
      params = { to: email, issue: issue }
      params[:auth_code] = add_auth_code(email) if User.find_by(email: email).blank?
      FeedbackMailer.notification(params).deliver_later
    end
  end

  def add_auth_code(email)
    AuthCode.find_or_create_by(issue: issue, group: Group.find_by(email: email))
  end

  def notify_responsible_group
    auth_code = AuthCode.find_or_create_by(issue: issue, group: issue.group)
    FeedbackMailer.notification(issue: issue, auth_code: auth_code).deliver_later
  end
end
