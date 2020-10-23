# frozen_string_literal: true

class Group < ApplicationRecord
  enum kind: { internal: 0, external: 1, field_service_team: 2 }, _prefix: true

  belongs_to :instance
  belongs_to :user

  has_many :jobs, dependent: :destroy

  scope :active, -> { where(active: true) }

end
