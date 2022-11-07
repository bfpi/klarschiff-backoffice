# frozen_string_literal: true

class Settings
  # Defines accessors for application configuration with values
  # defined in config/settings.yml
  # Each root node becomes an own module to scope the options

  (@config ||= Config.for(:settings)).with_indifferent_access.each do |context, options|
    m = Module.new
    options.each do |name, value|
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end

  class << self
    def main_instance?
      Instance.parent_instance_url.blank?
    end

    def area_level
      main_instance? ? Citysdk::Authority : Citysdk::District
    end

    def required_password_characters
      %i[number lowercase capital special_character]
        .select { |c| Password.send(:"include_#{c}") }
    end
  end
end
