# frozen_string_literal: true

class Instance < ApplicationRecord
  validates :area, :url, presence: true
  validates :name, presence: true, uniqueness: true
end
