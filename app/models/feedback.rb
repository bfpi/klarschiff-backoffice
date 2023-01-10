# frozen_string_literal: true

class Feedback < ApplicationRecord
  include AuthorBlacklist
  include FullTextFilter
  include Logging

  belongs_to :issue

  validates :author, :message, presence: true

  before_create :set_recipient
  after_create :notify

  default_scope -> { order created_at: :desc }

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    where issue_id: Issue.authorized(user)
  end

  def to_s
    "##{id}"
  end

  private

  def set_recipient
    self.recipient = identify_recipients
  end

  def identify_recipients
    group = issue.delegation || issue.group
    return identify_recipients_from_user(issue.updated_by_user, group) if issue.updated_by_user
    return issue.updated_by_auth_code.group.feedback_recipient if issue.updated_by_auth_code
    group.feedback_recipient
  end

  def identify_recipients_from_user(user, group)
    return user.email if user.group_feedback_recipient && group.in?(user.groups)
    users = group.users.where(group_feedback_recipient: true)
    return users.pluck(:email).join(', ') if users.any?
    group.feedback_recipient
  end

  def notify
    return notify_responsible_group if recipient.blank?
    recipient.split(', ').each do |email|
      FeedbackMailer.notification(**notify_feedback_mailer_params(email)).deliver_later
    end
  end

  def notify_feedback_mailer_params(email)
    params = { to: email, issue: }
    params[:auth_code] = auth_code(email) if User.find_by(case_insensitive_comparision(:email, email)).blank?
    params
  end

  def auth_code(email)
    AuthCode.find_or_create_by(issue:, group: Group.find_by(group_arel_table[:email].lower.eq(email.downcase)))
  end

  def notify_responsible_group
    auth_code = AuthCode.find_or_create_by(issue:, group: issue.group)
    FeedbackMailer.notification(issue:, auth_code:).deliver_later
  end

  def full_text_content
    [author, message].join(' ')
  end
end
