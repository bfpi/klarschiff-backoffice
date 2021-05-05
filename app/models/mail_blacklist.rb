# frozen_string_literal: true

class MailBlacklist < ApplicationRecord
  include Logging

  validates :pattern, :source, presence: true

  scope :active, -> { where active: true }

  def to_s
    pattern
  end
end
