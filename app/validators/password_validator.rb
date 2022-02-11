# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if password_valid?(value)
    record.errors.add(attribute, :invalid, length: pw_settings.min_length, required_characters: required_characters)
  end

  private

  def required_characters
    Settings.required_password_characters.map { |c| I18n.t("password.#{c}") }.join(', ')
  end

  def password_valid?(password)
    password.length >= pw_settings.min_length && characters_included(password)
  end

  def characters_included(password)
    Settings.required_password_characters.each do |char_type|
      return false unless password.match?(send(:"#{char_type}_format"))
    end
    true
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

  def pw_settings
    Settings::Password
  end
end
