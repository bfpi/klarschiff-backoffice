# frozen_string_literal: true

class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if password_valid?(value)
    record.errors.add(attribute, :invalid, length: pw_settings.min_length, required_characters: required_characters)
  end

  private

  def password_valid?(password)
    password.length >= pw_settings.min_length && characters_included(password)
  end

  def characters_included(password)
    %i[number lowercase capital special_character].each do |char_type|
      next unless pw_settings.send(:"include_#{char_type}")
      return false unless password.match?(send(:"#{char_type}_format"))
    end
    true
  end

  def required_characters
    %i[number lowercase capital special_character]
      .select { |c| pw_settings.send(:"include_#{c}") }.map { |c| I18n.t("password.#{c}") }.join(', ')
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
    @settings ||= Settings::Password
  end
end
