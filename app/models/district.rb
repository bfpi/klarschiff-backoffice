# frozen_string_literal: true

class District < ApplicationRecord
  belongs_to :community

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { conditions: -> { where(community: community) } }
end
