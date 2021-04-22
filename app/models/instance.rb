# frozen_string_literal: true

class Instance < ApplicationRecord
  has_many :groups, class_name: 'InstanceGroup', foreign_key: :reference_id, inverse_of: :instance, dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, presence: true
  validates :name, presence: true, uniqueness: true

  def to_s
    name
  end
end
