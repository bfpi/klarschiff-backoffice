# frozen_string_literal: true

class EditorialNotification < ApplicationRecord
  belongs_to :user

  validates :level, :repetition, presence: true
  validates :level, uniqueness: { scope: :user_id }

  delegate :first_name, :last_name, :email, :group_feedback_recipient, to: :user, prefix: true

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    where user_id: User.authorized(user).map(&:id)
  end
end
