# frozen_string_literal: true

class Issue
  module Callbacks
    module Responsibility
      extend ActiveSupport::Concern

      included do
        before_save :clear_group_responsibility_notified_at, if: -> { group_id_changed? && !responsibility_accepted }

        after_commit :create_issue_responsibility, if: :create_issue_responsibility?
        after_commit :update_issue_responsibility_accepted, if: :update_issue_responsibility_accepted?
        after_commit :notify_group, if: :notify_group_after_commit?
      end

      def notify_group
        update group_responsibility_notified_at: Time.current
        return notify_default_group_without_gui_access if default_group_without_gui_access?
        return if !group.reference_default? && (users = group.users.where(group_responsibility_recipient: true)).blank?
        ResponsibilityMailer.issue(self, **notify_group_options(users:)).deliver_later
      end

      def clear_group_responsibility_notified_at
        self.group_responsibility_notified_at = nil
      end

      def create_issue_responsibility?
        group_id.present? && saved_change_to_group_id?
      end

      def create_issue_responsibility
        issue_responsibilities.create group_id: group_id
      end

      def update_issue_responsibility_accepted?
        saved_change_to_responsibility_accepted? && !saved_change_to_group_id?
      end

      def update_issue_responsibility_accepted
        issue_responsibilities.last.update accepted: responsibility_accepted
      end

      def notify_default_group_without_gui_access
        ResponsibilityMailer.default_group_without_gui_access(self, **notify_group_options).deliver_later
      end
    end
  end
end
