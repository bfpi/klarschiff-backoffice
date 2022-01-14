# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_validation :strip_input_fields

  def self.human_enum_name(enum_name, value)
    I18n.t "enums.#{model_name.i18n_key}.#{enum_name}.#{value}", default: I18n.t("enums.#{enum_name}.#{value}")
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

  class PasswordValidator < ActiveModel::EachValidator
    NUMBER_FORMAT = /\d/
    LOWERCASE_FORMAT = /[a-z]/
    CAPITAL_FORMAT = /[A-Z]/

    def validate_each(record, attribute, value)
      record.errors.add(attribute, :invalid) unless password_valid?(value)
    end

    private

    def password_valid?(password)
      password.length >= 8 && included_characters(password) == 3
    end

    def included_characters(password)
      chars = 0
      %i[number lowercase capital].each do |char_type|
        chars += 1 if password.match?(send(:"#{char_type}_format"))
      end
      chars
    end

    def number_format
      /\d/
    end

    def lowercase_format
      /[a-z]/
    end

    def capital_format
      /[A-Z]/
    end
  end
end
