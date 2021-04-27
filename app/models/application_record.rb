# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_validation :strip_input_fields

  delegate :human_enum_name, to: :class

  def self.human_enum_name(enum_name, value)
    I18n.t "enums.#{model_name.i18n_key}.#{enum_name}.#{value}", default: I18n.t("enums.#{enum_name}.#{value}")
  end

  def strip_input_fields
    attributes.each do |name, value|
      self[name] = value.strip if value.respond_to?(:strip) && column_for_attribute(name).type == :text
    end
  end

  concerning :DateTimeAttributesWithBooleanAccessor do
    extend ActiveSupport::Concern

    included do
      unless abstract_class
        types = %i[date datetime]
        columns.select { |c| types.include? c.type }.each do |col|
          define_method "#{col.name}?" do
            self[col.name.to_sym].present?
          end
        end
      end
    end
  end
end
