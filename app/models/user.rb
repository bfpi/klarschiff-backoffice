# frozen_string_literal: true

class User < ApplicationRecord
  include FullTextFilter
  include Logging
  include UserAuthorization

  attr_accessor :auth_code

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

  store_accessor :password_history, :next_password_id, :passwords

  validates :last_name, :email, :role, presence: true
  validates :email, :login, uniqueness: true
  validates :email, email: { if: -> { email.present? } }
  validates :groups, presence: true, unless: :role_admin?
  validates :password_digest, presence: true, if: -> { ldap.blank? }
  validates :password_confirmation, presence: true, if: -> { ldap.blank? && password_digest_changed? }
  validates :password, password: true, confirmation: true, allow_blank: true
  validate :password_rotation, if: :password_history_active?
  validate :role_permissions

  before_save :maintain_password_history, if: :password_history_active?

  default_scope -> { order :last_name, :first_name }
  scope :active, -> { where(active: true) }

  def self.authorized(user = Current.user)
    return all if user&.role_admin?
    return none unless user&.role_regional_admin?
    not_role_admin.eager_load(:groups).where(group: { id: Group.active.authorized(user) })
  end

  def to_s
    [last_name, first_name].filter_map(&:presence).join ', '
  end

  def as_json(_options = {})
    { value: id, label: to_s }
  end

  def uuid
    update uuid: SecureRandom.uuid if self[:uuid].blank?
    self[:uuid]
  end

  private

  def password_history_active?
    Settings::Password.password_history.positive?
  end

  def password_digest_changed_from
    changes.dig(:password_digest, 0)
  end

  def old_password_digests
    (passwords || []).pluck('password_digest')
  end

  def password_rotation
    return if @password.blank? || @password != @password_confirmation
    taken = [*old_password_digests, password_digest_changed_from].any? do |hash|
      ::BCrypt::Password.valid_hash?(hash) && ::BCrypt::Password.new(hash) == @password
    end
    errors.add :password, :taken if taken
  end

  def maintain_password_history
    return if password_digest_changed_from.blank? || !password_digest_changed?
    change_time = Time.current
    id = (next_password_id || 0).to_i
    add_to_password_history(id, change_time)
    self.next_password_id = (id + 1) % Settings::Password.password_history
    self.password_updated_at = change_time
  end

  def add_to_password_history(password_id, change_time)
    self.passwords ||= []
    self.passwords[password_id] = {
      password_digest: password_digest_changed_from, valid_from: password_updated_at, valid_until: change_time
    }
  end

  def role_permissions
    return true unless Current.user && !Current.user.auth_code
    if self.class.roles[role] < Current.user.read_attribute_before_type_cast(:role)
      errors.add :role, :invalid_permissions
      return false
    end
    true
  end

  def full_text_content
    [last_name, first_name, login, human_enum_name(:role)].join(' ')
  end
end
