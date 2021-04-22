# frozen_string_literal: true

class MainCategory < ApplicationRecord
  include Logging

  has_many :categories, dependent: :destroy
  has_many :sub_categories, through: :categories

  enum kind: { idea: 0, problem: 1, tip: 2 }, _prefix: true

  validates :kind, :name, presence: true

  scope :active, -> { where.not deleted: true }

  def to_s
    name
  end

  def kind_name
    human_enum_name :kind, kind
  end
end
