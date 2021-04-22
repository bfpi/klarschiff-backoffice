# frozen_string_literal: true

class SubCategory < ApplicationRecord
  include Logging

  has_many :categories, dependent: :destroy
  has_many :main_categories, through: :categories

  validates :name, presence: true

  scope :active, -> { where.not deleted: true }

  def to_s
    name
  end
end
