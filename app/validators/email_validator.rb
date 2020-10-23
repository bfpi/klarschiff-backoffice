# frozen_string_literal: true

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :email, value: value) unless
      /\A([^@\s]+)@((?:[-a-z0-9_]+\.)+[a-z]{2,})\z/i.match?(value)
  end
end
