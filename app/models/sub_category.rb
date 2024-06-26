# frozen_string_literal: true

class SubCategory < ApplicationRecord
  include Logging

  mattr_reader :config, default: Config.for(:dms)

  has_many :categories, dependent: :destroy
  has_many :main_categories, through: :categories

  validates :name, presence: true

  scope :active, -> { where.not deleted: true }

  def to_s
    name
  end

  def dms_link
    target, ddc = dms.try(:split, ':')
    return if target.blank? || ddc.blank?
    config.dig target, :create_link, ddc
  end
end
