# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.2'
# Use Puma as the app server
gem 'puma', '~> 6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.12'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'erb_lint', require: false
  gem 'minitest'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'

  gem 'brakeman'
  gem 'bullet'
  gem 'pronto-rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
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
gem 'exception_notification'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', github: 'jquery-ui-rails/jquery-ui-rails', tag: 'v7.0.0'
gem 'kaminari'
gem 'net-ldap'
gem 'pdfkit'
gem 'rails-i18n'
gem 'rubyXL'
