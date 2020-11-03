# frozen_string_literal: true

class Category < ApplicationRecord
  belongs_to :main_category
  belongs_to :sub_category

  with_options dependent: :destroy do
    has_many :issues
    has_many :responsibilities
  end

  delegate :kind, :kind_name, :sub_categories, to: :main_category
  delegate :name, to: :main_category, prefix: true
  delegate :name, to: :sub_category, prefix: true

  def to_s
    [main_category, sub_category].join(' - ')
  end

  def group
    responsibilities&.first&.group
  end
end
