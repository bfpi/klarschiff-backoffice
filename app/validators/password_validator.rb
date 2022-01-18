# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
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
