# frozen_string_literal: true

class User < ApplicationRecord
  include Logging

  has_and_belongs_to_many :group
  has_and_belongs_to_many :district
  has_and_belongs_to_many :field_service_team, class_name: 'Group', join_table: :field_service_team_operator

  enum role: { admin: 0, regional_admin: 1, editor: 2 }, _prefix: true

  validates :email, :status, presence: true
  validates :email, :login, uniqueness: true
end
