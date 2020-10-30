# frozen_string_literal: true

class County < ApplicationRecord
  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: true
end
