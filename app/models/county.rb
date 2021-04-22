# frozen_string_literal: true

class County < ApplicationRecord
  has_many :groups, class_name: 'CountyGroup', foreign_key: :reference_id, inverse_of: :county, dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: true
end
