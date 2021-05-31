# frozen_string_literal: true

class JobSettings
  # Defines accessors for application configuration with values
  # defined in config/jobs.yml
  # Each root node becomes an own module to scope the options

  (@config ||= Config.for(:jobs)).each do |context, options|
    m = Module.new
    options.each do |name, value|
      m.define_singleton_method(name) { value }
    end
    const_set context.classify, m
  end
end
