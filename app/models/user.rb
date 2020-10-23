# frozen_string_literal: true

class User < ApplicationRecord
  include Authorization
  include Logging

  has_secure_password(validations: false)

  self.omit_field_log_values += %w[password_digest password_history]

  enum role: { admin: 0, regional_admin: 1, editor: 2 }, _prefix: true

  has_and_belongs_to_many :group
  has_and_belongs_to_many :district
  has_and_belongs_to_many :field_service_team, class_name: 'Group', join_table: :field_service_team_operator

  validates :email, :role, presence: true
  validates :email, :login, uniqueness: true
  validates :email, email: { if: -> { email.present? } }

  scope :active, -> { where(active: true) }

  def to_s
    [first_name, last_name].join(' ')
  end
end
