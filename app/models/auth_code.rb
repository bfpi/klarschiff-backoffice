# frozen_string_literal: true

class AuthCode < ApplicationRecord
  belongs_to :issue
  belongs_to :group

  validates :uuid, presence: true

  before_validation :set_uuid, on: :create

  delegate :to_s, to: :group

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end
end
