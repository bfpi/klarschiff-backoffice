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
    when :change_password then ldap.blank?
    when :delegations, :issues, :jobs then index_permitted?(action)
    when :create_issue, :edit_delegation, :edit_issue, :change_issue_status then edit_permitted?(action, object)
    when :resend_responsibility then resend_responsibility(object)
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
    when :change_issue_status then change_issue_status_permitted?(object)
    when :create_issue then create_issue_permitted?
    when :edit_delegation then edit_delegation_permitted?(object)
    when :edit_issue then edit_issue_permitted?(object)
    end
  end

  def resend_responsibility(object)
    static_permitted_to?(:resend_responsibility) && object.group.reference_default
  end

  def issues_permitted?
    static_permitted_to?(:issues) || groups.active.any?(&:kind_internal?) ||
      auth_code_gui_access? && auth_code&.group&.kind_internal?
  end

  def change_issue_status_permitted?(issue)
    auth_code&.group_id == issue.group_id && issue.group.reference_default
  end

  def create_issue_permitted?
    static_permitted_to?(:issues) || groups.active.any?(&:kind_internal?)
  end

  def edit_issue_permitted?(issue)
    static_permitted_to?(:issues) || groups.active.ids.include?(issue.group_id) ||
      auth_code_gui_access? && auth_code&.issue_id == issue.id && auth_code.group_id == issue.group_id
  end

  def delegations_permitted?
    static_permitted_to?(:delegations) || groups.active.where(kind: %i[internal external]).any? ||
      auth_code_gui_access? && auth_code&.group&.kind_external?
  end

  def edit_delegation_permitted?(issue)
    edit_issue_permitted?(issue) ||
      static_permitted_to?(:delegations) || groups.active.ids.include?(issue.delegation_id) ||
      auth_code_gui_access? && auth_code&.issue_id == issue.id && auth_code.group_id == issue.delegation_id
  end

  def static_permitted_to?(action)
    id.present? && static_permissions.include?(action)
  end

  def permitted_group_types
    return [] if role_editor?
    return %w[CountyGroup AuthorityGroup] & Group.authorized(self).distinct.pluck(:type) if role_regional_admin?
    %w[InstanceGroup CountyGroup AuthorityGroup]
  end

  def auth_code_gui_access?
    Settings::Instance.auth_code_gui_access_for_external_participants
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
    manage_mail_blacklist: %i[admin],
    manage_mail_templates: %i[admin],
    manage_responsibilities: %i[admin regional_admin],
    manage_users: %i[admin regional_admin],
    resend_responsibility: %i[admin],
    test: %i[admin],
    view_dashboard: %i[admin regional_admin editor]
  }.freeze

  class NotAuthorized < StandardError
    def initialize(action, object = nil)
      msg = "#{Current.user} is not authorized to #{action}."
      msg += "\n  Context object: #{object.inspect}" if object
      super(msg)
    end
  end
end
