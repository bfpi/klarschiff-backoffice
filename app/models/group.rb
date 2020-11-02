# frozen_string_literal: true

class Group < ApplicationRecord
  include Logging

  enum kind: { internal: 0, external: 1, field_service_team: 2 }, _prefix: true

  belongs_to :main_user, class_name: 'User'

  has_and_belongs_to_many :field_service_operator, class_name: 'User', join_table: :field_service_team_operator, association_foreign_key: :operator_id, foreign_key: :field_service_team_id
  has_and_belongs_to_many :user

  validates :name, :short_name, presence: true

  scope :active, -> { where(active: true) }

  def to_s
    name
  end

  def as_json(_options = {})
    { value: id, label: to_s }
  end
end
