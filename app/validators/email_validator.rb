# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? || /\A([^@\s]+)@((?:[-a-z0-9_]+\.)+[a-z]{2,})\z/i.match?(value)
    record.errors.add attribute, :email, value: value
  end
end
