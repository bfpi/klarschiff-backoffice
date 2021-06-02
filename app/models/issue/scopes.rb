# frozen_string_literal: true

class Issue
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :not_archived, -> { where(archived_at: nil) }
      scope :status_open, -> { where(status: %w[received reviewed in_process]) }
      scope :status_solved, -> { where(status: %w[duplicate not_solvable closed]) }
    end

    class_methods do # rubocop:disable Metrics/BlockLength
      def authorized(user = Current.user)
        return all if user&.role_admin?
        authorized_group_ids = authorized_group_ids(user)
        where(authorized_area_issue_ids(authorized_group_ids))
          .where(Issue.arel_table[:group_id].in(authorized_group_ids)
            .or(Issue.arel_table[:delegation_id].in(authorized_group_ids)))
      end

      def authorized_group_ids(user = Current.user)
        return user.group_ids unless user&.role_regional_admin?
        user.groups.map { |gr| Group.where(type: gr.type, reference_id: gr.reference_id) }.flatten.map(&:id)
      end

      def authorized_area_issue_ids(group_ids)
        groups = Group.where(id: group_ids)
        'ST_Within(position, '\
          "(SELECT ST_Multi(ST_CollectionExtract(st_polygonize(ST_Boundary(cou.area)), 3)) FROM #{
            County.table_name} cou where cou.id in (#{groups.map(&:reference_id).join(',')}))) OR "\
            'ST_Within(position, (SELECT ST_Multi(ST_CollectionExtract(st_polygonize('\
            "ST_Boundary(aut.area)), 3)) FROM #{Authority.table_name} aut where aut.id in (#{
            groups.map(&:reference_id).join(',')})))"
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
