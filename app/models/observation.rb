# frozen_string_literal: true

class Observation < ApplicationRecord
  include Logging

  validates :key, presence: true, uniqueness: true
  validates :area, :category_ids, presence: true

  before_validation :set_key, on: :create

  def categories
    return [] if category_ids.blank?
    Category.where(id: category_ids.split(',').map(&:to_i))
  end

  private

  def set_key
    self.key = SecureRandom.uuid
  end
end
