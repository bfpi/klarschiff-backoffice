# frozen_string_literal: true

class Photo < ApplicationRecord
  include Logging

  belongs_to :issue
  as_one_attached :file

  enum status: { internal: 0, external: 1, deleted: 2 }, _prefix: true

  validates :confirmation_hash, presence: true, uniqueness: true
  validates :file, presence: true

  before_validation :set_confirmation_hash, on: :create

  private

  def set_confirmation_hash
    self.confirmation_hash = SecureRandom.uuid
  end
end
