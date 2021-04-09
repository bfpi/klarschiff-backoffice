# frozen_string_literal: true

class Community < ApplicationRecord
  belongs_to :authority

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { scope: :authority }
end
