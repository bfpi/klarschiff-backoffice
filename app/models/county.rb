# frozen_string_literal: true

class County < ApplicationRecord
  belongs_to :instance

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { conditions: -> { where(instance: instancer) } }
end
