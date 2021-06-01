# frozen_string_literal: true

class Instance < ApplicationRecord
  include Citysdk::Serialization

  has_many :groups, class_name: 'InstanceGroup', foreign_key: :reference_id, inverse_of: :instance, dependent: :destroy
  has_many :responsibilities, through: :groups

  validates :area, presence: true
  validates :name, presence: true, uniqueness: true

  self.serialization_attributes = %i[id name grenze]

  alias_attribute :grenze, :area

  scope :current, -> { where instance_url: nil }

  def to_s
    name
  end
end
