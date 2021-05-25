# frozen_string_literal: true

module UserAuthorization
  extend ActiveSupport::Concern

  def static_permissions
    @static_permissions ||= STATIC_PERMISSIONS.select { |_, roles| roles.any? { |name| send :"role_#{name}?" } }.keys
  end

  def authorized?(action, _object = nil)
    return false unless active?
    case action
    when :administration then administration_permitted?
    when :jobs then groups.any?(&:kind_field_service_team?)
    when :manage_delegations then delegation_permitted?
    else
      static_permitted_to? action
    end
  end

  def administration_permitted?
    (%i[list_log_entries test] | STATIC_PERMISSIONS.keys.select { |k| k.to_s.starts_with? 'manage_' })
      .any? { |permission| authorized? permission }
  end

  def delegation_permitted?
    static_permitted_to?(:manage_delegations) || groups.any?(&:kind_internal?)
  end

  def static_permitted_to?(action)
    static_permissions.include? action
  end

  STATIC_PERMISSIONS = {
    change_user: %i[admin],
    list_log_entries: %i[admin regional_admin],
    manage_delegations: %i[admin regional_admin],
    manage_editorial_notifications: %i[admin regional_admin],
    manage_feedbacks: %i[admin regional_admin],
    manage_field_service: %i[admin regional_admin],
    manage_groups: %i[admin regional_admin],
    manage_mail_blacklist: %i[admin regional_admin],
    manage_mail_templates: %i[admin],
    manage_responsibilities: %i[admin regional_admin],
    manage_users: %i[admin regional_admin],
    test: %i[admin]
  }.freeze

  class NotAuthorized < StandardError
    def initialize(action, object = nil)
      msg = "#{Current.user} is not authorized to #{action}."
      msg += "\n  Context object: #{object.inspect}" if object
      super msg
    end
  end
end
