# frozen_string_literal: true

class Issue
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :not_archived, -> { where(archived_at: nil) }
      scope :open, -> { where(status: %w[received reviewed]) }

      def self.by_kind(kind)
        includes(category: :main_category).where(main_category: { kind: kind })
      end

      def self.not_approved
        includes(:photos).where(
          description_status: %i[internal deleted], photo: { status: %i[internal deleted] }
        )
      end

      def self.unsupported
        by_kind(0).eager_load(:supporters).where(supporters_sql)
      end

      def self.supporters_sql(comp = '<')
        Arel.sql(<<~SQL.squish)
          (
            SELECT COUNT(s.id)
            FROM #{Supporter.table_name} "s" WHERE "s"."issue_id" = "issue"."id"
          ) #{comp} #{Settings::Vote.min_requirement}
        SQL
      end
    end
  end
end
