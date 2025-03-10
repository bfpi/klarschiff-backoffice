# frozen_string_literal: true

class MailBlacklist < ApplicationRecord
  include FullTextFilter
  include Logging

  validates :pattern, :source, presence: true

  scope :active, -> { where active: true }

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    none
  end

  def to_s
    pattern
  end

  private

  def full_text_content
    [pattern, source].join(' ')
  end
end
