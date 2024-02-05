require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require "action_cable/engine"
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KlarschiffBackoffice
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = 'Europe/Berlin'

    config.active_record.pluralize_table_names = false

    config.action_mailer.show_previews = true

    config.assets.precompile += %w[ol.css]

    config.generators do |g|
      g.assets false
      g.helper false
    end

    config.i18n.default_locale = :de
    config.i18n.available_locales = %i[de en]

    config.active_storage.content_types_allowed_inline << 'image/jpg'
    config.active_storage.variable_content_types << 'image/jpg'

    # Global settings from settings.yml
    settings_file = Rails.root.join('config/settings.yml')
    if File.file?(settings_file)
      settings = settings_file.open do |file|
        YAML.load file, aliases: true
      end.with_indifferent_access[Rails.env]

      relative_url_root = settings.dig(:instance, :relative_url_root)
      config.relative_url_root = relative_url_root if relative_url_root.present?
    end
  end
end
