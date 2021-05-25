# frozen_string_literal: true

class District < ApplicationRecord
  include Citysdk::Serialization

  belongs_to :authority

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { conditions: -> { where(authority: authority) } }

  self.serialization_attributes = %i[id name grenze]

  alias_attribute :grenze, :area
end
