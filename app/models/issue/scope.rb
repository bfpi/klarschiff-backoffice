# frozen_string_literal: true

class Issue
  module Scope
    extend ActiveSupport::Concern

    module ClassMethods
      def by_kind(kind)
        includes(category: :main_category).where(main_category: { kind: kind })
      end

      def unsupported
        eager_load(:supporters).by_kind('idea').where(status: 'reviewed').where(supporters_sql)
      end

      def supported
        eager_load(:supporters).by_kind('idea').where(status: 'reviewed').where(supporters_sql('>='))
      end

      def supporters_sql(comp = '<')
        Arel.sql(<<~SQL.squish)
          (SELECT COUNT(s.id) FROM supporter s WHERE s.issue_id = issue.id) #{comp} #{Settings::Vote.min_requirement}
        SQL
      end
    end
  end
end
