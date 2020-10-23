# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  def admin?
    role_admin? || role_regional_admin?
  end

  def static_permissions
    @static_permissions ||= STATIC_PERMISSIONS.select { |_, roles| roles.any? { |name| send :"#{name}?" } }.keys
  end

  def authorized?(action)
    action.in? static_permissions
  end

  STATIC_PERMISSIONS = {
    groups: %i[admin regional_admin],
    users: %i[admin regional_admin]
  }.freeze

  class NotAuthorized < StandardError
    def initialize(action, object = nil)
      msg = "#{Current.user} is not authorized to #{action}."
      msg += "\n  Context object: #{object.inspect}" if object
      super msg
    end
  end
end
