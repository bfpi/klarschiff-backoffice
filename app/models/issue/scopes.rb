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
