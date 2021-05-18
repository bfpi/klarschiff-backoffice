# frozen_string_literal: true

module ConfirmationWithHash
  extend ActiveSupport::Concern

  included do
    before_validation :set_confirmation_hash

    validates :confirmation_hash, presence: true, uniqueness: true
  end

  private

  def set_confirmation_hash
    self.confirmation_hash ||= SecureRandom.uuid
  end
end
