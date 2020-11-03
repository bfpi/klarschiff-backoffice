# frozen_string_literal: true

module UserAuthorization
  extend ActiveSupport::Concern

  def static_permissions
    @static_permissions ||= STATIC_PERMISSIONS.select { |_, roles| roles.any? { |name| send :"role_#{name}?" } }.keys
  end

  def authorized?(action, _object = nil)
    return false unless active?
    case action
    when :administration
      %i[manage_users manage_groups all_log_entries manage_editorial_notifications
         manage_mail_blacklist].any? { |permission| authorized?(permission) }
    when :jobs
      group.any?(&:kind_field_service_team?)
    else
      static_permitted_to? action
    end
  end

  def static_permitted_to?(action)
    static_permissions.include? action
  end

  STATIC_PERMISSIONS = {
    list_log_entries: %i[admin regional_admin],
    change_user: %i[admin],
    manage_editorial_notifications: %i[admin regional_admin],
    manage_feedbacks: %i[admin regional_admin],
    manage_field_service: %i[admin regional_admin],
    manage_groups: %i[admin regional_admin],
    manage_mail_blacklist: %i[admin regional_admin],
    manage_users: %i[admin regional_admin]
  }.freeze

  class NotAuthorized < StandardError
    def initialize(action, object = nil)
      msg = "#{Current.user} is not authorized to #{action}."
      msg += "\n  Context object: #{object.inspect}" if object
      super msg
    end
  end
end
