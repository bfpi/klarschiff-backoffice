# frozen_string_literal: true

class EditorialNotification < ApplicationRecord
  belongs_to :user

  validates :level, :repetition, presence: true
  validates :level, uniqueness: { conditions: -> { where(user: user) } }
end
