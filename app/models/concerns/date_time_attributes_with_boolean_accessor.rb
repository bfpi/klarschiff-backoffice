# frozen_string_literal: true

module DateTimeAttributesWithBooleanAccessor
  extend ActiveSupport::Concern

  included do
    next if ARGV.include?('db:migrate')
    types = %i[date datetime]
    columns.select { |c| types.include? c.type }.each do |col|
      define_method :"#{col.name}?" do
        self[col.name.to_sym].present?
      end
    end
  end
end
