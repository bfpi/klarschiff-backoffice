# frozen_string_literal: true

class MailBlacklist < ApplicationRecord
  include Logging

  validates :pattern, :source, presence: true

  def to_s
    pattern
  end
end
