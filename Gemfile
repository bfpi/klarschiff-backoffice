# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 4.0.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.6.3'
# Use Puma as the app server
gem 'puma', '~> 8.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem 'solid_cable'
# gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  gem 'minitest'
  gem 'minitest-mock'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem 'listen', '~> 3.2'
  # gem 'web-console', '>= 3.3.0'

  gem 'bullet'
  gem 'pronto-rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'

  gem 'erb_lint', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

gem 'activerecord-postgis-adapter'
gem 'active_storage_validations'
gem 'bootstrap', '~> 5.1.3' # CSS variable usage in v5.2.x is incomplete until Bootstrap 6
gem 'bootstrap-datepicker-rails'
gem 'coffee-rails'
gem 'connection_pool', '< 3.0'
gem 'exception_notification'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'net-ldap'
gem 'pdfkit'
gem 'rails-i18n'
gem 'rubyXL'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq-cron'
