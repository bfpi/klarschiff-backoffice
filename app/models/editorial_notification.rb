# frozen_string_literal: true

class EditorialNotification < ApplicationRecord
  belongs_to :user

  validates :level, :repetition, presence: true
  validates :level, uniqueness: { scope: :user_id }

  delegate :first_name, :last_name, :email, :group_feedback_recipient, to: :user, prefix: true
end
