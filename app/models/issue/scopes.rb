# frozen_string_literal: true

class Issue
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :not_archived, -> { where(archived_at: nil) }
      scope :status_open, -> { where(status: %w[received reviewed in_process]) }
      scope :status_solved, -> { where(status: %w[duplicate not_solvable closed]) }
    end

    class_methods do
      def authorized(user = Current.user)
        return all if user&.role_admin?
        authorized_group_ids = authorized_groups(user)
        where Issue.arel_table[:group_id].in(authorized_group_ids)
          .or(Issue.arel_table[:delegation_id].in(authorized_group_ids))
      end

      def authorized_groups(user = Current.user)
        return user.groups.map(&:id) unless user&.role_regional_admin?
        user.groups.map { |gr| Group.where(type: gr.type, reference_id: gr.reference_id) }.flatten.map(&:id)
      end

      def by_kind(kind)
        includes(category: :main_category).where(main_category: { kind: kind })
      end

      def not_approved
        includes(:photos).where(
          description_status: %i[internal deleted], photo: { status: %i[internal deleted] }
        )
      end

      def ideas_without_min_supporters
        by_kind(0).having Supporter.arel_table[:id].count.lt(Settings::Vote.min_requirement)
      end

      def ideas_with_min_supporters
        by_kind(0).having Supporter.arel_table[:id].count.gteq(Settings::Vote.min_requirement)
      end
    end
  end
end
