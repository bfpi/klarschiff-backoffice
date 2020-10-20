# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :instance

  has_many :jobs, dependent: :destroy

  enum kind: { internal: 0, external: 1, field_service_team: 2 }, _prefix: true
end
