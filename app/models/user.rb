# frozen_string_literal: true

class User < ApplicationRecord
  include Logging
  include UserAuthorization

  has_secure_password(validations: false)

  self.omit_field_log_values += %w[password_digest password_history]

  enum role: { admin: 0, regional_admin: 1, editor: 2 }, _prefix: true

  with_options after_add: :log_habtm_add, after_remove: :log_habtm_remove do
    has_and_belongs_to_many :groups
    has_and_belongs_to_many :districts
    has_and_belongs_to_many :field_service_teams, class_name: 'Group',
                                                  join_table: :field_service_team_operator,
                                                  foreign_key: :operator_id,
                                                  association_foreign_key: :field_service_team_id
  end

  validates :last_name, :email, :role, presence: true
  validates :email, :login, uniqueness: true
  validates :email, email: { if: -> { email.present? } }
  validate :role_permissions

  default_scope -> { order :last_name, :first_name }
  scope :active, -> { where(active: true) }

  def self.authorized(user = Current.user)
    if user&.role_admin?
      all
    else
      where(User.arel_table[:role].in(User.roles.keys.to_a.map(&:to_sym) - [:admin]))
    end
  end

  def to_s
    [first_name, last_name].filter_map(&:presence).join ' '
  end

  def as_json(_options = {})
    { value: id, label: to_s }
  end

  private

  def role_permissions
    return true unless Current.user
    if self.class.roles[role] < Current.user.read_attribute_before_type_cast(:role)
      errors.add :role, :invalid_permissions
      return false
    end
    true
  end
end
