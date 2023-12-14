# frozen_string_literal: true

class Issue
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :not_archived, -> { where(archived_at: nil) }
      scope :status_open, -> { where(status: %w[received reviewed in_process]) }
      scope :status_solved, -> { where(status: %w[not_solvable duplicate closed]) }
    end

    class_methods do # rubocop:disable Metrics/BlockLength
      def authorized(user = Current.user)
        return auth_code_issues(user.auth_code) if user.auth_code
        return all if user&.role_admin?
        authorized_group_ids = authorized_group_ids(user)
        authorized_by_areas_for(authorized_group_ids)
          .where(Issue.arel_table[:group_id].in(authorized_group_ids)
            .or(Issue.arel_table[:delegation_id].in(authorized_group_ids)))
          .authorized_by_user_districts
      end

      def by_kind(kind)
        includes(category: :main_category).where(main_category: { kind: })
      end

      def description_not_approved
        where(status: %w[reviewed in_process not_solvable duplicate closed])
          .where(description_status: %i[internal deleted])
          .order(id: :asc)
      end

      def photos_not_approved
        where(status: %w[reviewed in_process not_solvable duplicate closed])
          .where(id: Photo.select(:issue_id).where(status: %i[internal deleted]))
          .where.not(id: Photo.select(:issue_id).where(status: :external))
          .order(id: :asc)
      end

      def ideas_without_min_supporters
        by_kind(0).having Supporter.arel_table[:id].count.lt(Settings::Vote.min_requirement)
      end

      def ideas_with_min_supporters
        by_kind(0).having Supporter.arel_table[:id].count.gteq(Settings::Vote.min_requirement)
      end

      def authorized_by_user_districts(user = Current.user)
        return all if user.blank? || user.districts.blank?
        where <<~SQL.squish, user.district_ids
          ST_Within("position", (
            SELECT ST_Multi(ST_CollectionExtract(ST_Polygonize(ST_Boundary("area")), 3))
            FROM #{District.quoted_table_name}
            WHERE "id" IN (?)
          ))
        SQL
      end

      def open_abuse_reports
        joins(:abuse_reports).where(abuse_reports: { resolved_at: nil }).order(:id)
      end

      def open_completions
        joins(:completions).merge(Completion.status_open).order(:id)
      end

      private

      def auth_code_issues(auth_code)
        issues = where(id: auth_code.issue_id)
        issues = issues.where(group_id: auth_code.group_id) if auth_code.group.kind_internal?
        issues = issues.where(delegation_id: auth_code.group_id) if auth_code.group.kind_external?
        issues
      end

      def authorized_by_areas_for(group_ids)
        reference_ids = Group.active.where(id: group_ids).distinct.pluck(:reference_id)
        return none if reference_ids.blank?
        authorized_by_references(reference_ids)
      end

      def authorized_by_references(reference_ids)
        where <<~SQL.squish, reference_ids, reference_ids
          ST_Within("position", (
            SELECT ST_Multi(ST_CollectionExtract(ST_Polygonize(ST_Boundary("area")), 3))
            FROM #{County.quoted_table_name}
            WHERE "id" IN (?)
          )) OR ST_Within("position", (
            SELECT ST_Multi(ST_CollectionExtract(ST_Polygonize(ST_Boundary("area")), 3))
            FROM #{Authority.quoted_table_name} WHERE "id" IN (?)
          ))
        SQL
      end

      def authorized_group_ids(user = Current.user)
        return user.groups.active.ids unless user&.role_regional_admin?
        Group.authorized(user).ids # allow issues of inactive groups for regio admin
      end
    end
  end
end
