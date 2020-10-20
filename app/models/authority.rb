# frozen_string_literal: true

class Authority < ApplicationRecord
  belongs_to :county

  validates :area, :name, :regional_key, presence: true
  validates :name, uniqueness: { conditions: -> { where(county: county) } }
end
