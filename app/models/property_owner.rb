# frozen_string_literal: true

class PropertyOwner < ApplicationRecord
  validates :area, :parcel_key, presence: true
end
