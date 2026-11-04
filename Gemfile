# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 8.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Use the database-backed adapters for Active Job
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing'
gem 'mini_magick'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: :mri, require: 'debug/prelude'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  gem 'erb_lint', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'

  gem 'minitest-mock'
end

gem 'activerecord-postgis-adapter'
gem 'active_storage_validations'
gem 'bootstrap', '~> 5.1.3' # CSS variable usage in v5.2.x is incomplete until Bootstrap 6
gem 'bootstrap-datepicker-rails'
gem 'coffee-rails'
gem 'csv'
gem 'exception_notification'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'mission_control-jobs'
gem 'net-ldap'
gem 'pdfkit'
gem 'rails-i18n'
gem 'rubyXL'
gem 'sass-rails'
gem 'turbolinks'
