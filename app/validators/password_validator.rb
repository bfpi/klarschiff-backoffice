# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  mattr_accessor :min_length, default: Settings::Password.min_length
  mattr_accessor :required_characters,
    default: Settings.required_password_characters.map { |c| t("password.#{c}") }.join(', ')

  def validate_each(record, attribute, value)
    return if password_valid?(value)
    record.errors.add attribute, :invalid, length: min_length, required_characters:
  end

  private

  def password_valid?(password)
    password.length >= min_length && characters_included?(password)
  end

  def characters_included?(password)
    Settings.required_password_characters.all? do |char_type|
      password.match? send(:"#{char_type}_format")
    end
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

  def special_character_format
    /[^\w\s]/
  end
end
