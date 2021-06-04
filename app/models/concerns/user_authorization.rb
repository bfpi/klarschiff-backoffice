# frozen_string_literal: true

module UserAuthorization
  extend ActiveSupport::Concern

  def static_permissions
    @static_permissions ||= STATIC_PERMISSIONS.select { |_, roles| roles.any? { |name| send :"role_#{name}?" } }.keys
  end

  def authorized?(action, object = nil)
    return false unless active?
    case action
    when :administration then administration_permitted?
    when :delegations, :issues, :jobs then index_permitted?(action)
    when :create_issue, :edit_delegation, :edit_issue then edit_permitted?(action, object)
    else
      static_permitted_to? action
    end
  end

  def administration_permitted?
    (%i[list_log_entries test] | STATIC_PERMISSIONS.keys.select { |k| k.to_s.starts_with? 'manage_' })
      .any? { |permission| authorized? permission }
  end

  def index_permitted?(action)
    case action
    when :delegations then delegations_permitted?
    when :issues then issues_permitted?
    when :jobs then field_service_teams.any?
    end
  end

  def edit_permitted?(action, object)
    case action
    when :create_issue then create_issue_permitted?
    when :edit_delegation then edit_delegation_permitted?(object)
    when :edit_issue then edit_issue_permitted?(object)
    end
  end

  def issues_permitted?
    static_permitted_to?(:issues) || groups.any?(&:kind_internal?) || auth_code&.group&.kind_internal?
  end

  def create_issue_permitted?
    static_permitted_to?(:issues) || groups.any?(&:kind_internal?)
  end

  def edit_issue_permitted?(issue)
    static_permitted_to?(:issues) || auth_code&.issue_id == issue.id
  end

  def delegations_permitted?
    static_permitted_to?(:delegations) || groups.any?(&:kind_internal?) || auth_code&.group&.kind_external?
  end

  def edit_delegation_permitted?(issue)
    static_permitted_to?(:delegations) || auth_code&.issue_id == issue.id
  end

  def static_permitted_to?(action)
    id.present? && static_permissions.include?(action)
  end

  STATIC_PERMISSIONS = {
    change_user: %i[admin],
    delegations: %i[admin regional_admin],
    issues: %i[admin regional_admin],
    list_log_entries: %i[admin regional_admin],
    manage_editorial_notifications: %i[admin regional_admin],
    manage_feedbacks: %i[admin regional_admin],
    manage_field_service: %i[admin regional_admin],
    manage_groups: %i[admin regional_admin],
    manage_mail_blacklist: %i[admin regional_admin],
    manage_mail_templates: %i[admin],
    manage_responsibilities: %i[admin regional_admin],
    manage_users: %i[admin regional_admin],
    test: %i[admin],
    view_dashboard: %i[admin regional_admin editor]
  }.freeze

  class NotAuthorized < StandardError
    def initialize(action, object = nil)
      msg = "#{Current.user} is not authorized to #{action}."
      msg += "\n  Context object: #{object.inspect}" if object
      super msg
    end
  end
end
