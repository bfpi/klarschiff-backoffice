# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ArelTable

  self.abstract_class = true

  before_validation :strip_input_fields

  def self.human_enum_name(enum_name, value)
    I18n.t "enums.#{model_name.i18n_key}.#{enum_name}.#{value}",
      default: I18n.t("enums.#{enum_name}.#{value}", default: '')
  end

  def to_s
    "##{id}"
  end

  def human_enum_name(enum_name)
    self.class.human_enum_name enum_name, self[enum_name]
  end

  def strip_input_fields
    attributes.each do |name, value|
      self[name] = value.strip if value.respond_to?(:strip) && column_for_attribute(name).type == :text
    end
  end
end
