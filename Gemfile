source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '~> 5.2.0'
gem 'puma', '~> 3.11'
gem 'unicorn'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'linked-list', '~> 0.0.13'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Audit model changes
gem 'paper_trail', '~> 10.1'
gem 'paper_trail-association_tracking', '~> 1.0'
# Administrator interface
gem 'rails_admin', '~> 1.3'
gem 'rails_admin_history_rollback', '~> 1.0', '>= 1.0.1'
# Background job processing
gem 'sidekiq'
gem 'sidekiq-cron', '~> 0.6.3'
gem 'rufus-scheduler', '~> 3.4.0' # needed as a bugfix for above
# Static page serving
gem 'high_voltage'
# OAuth login for Camdram
gem 'omniauth'
gem 'omniauth-camdram'
# Date/time handling
gem 'chronic'
gem 'chronic_duration'
gem 'datey'
# Humanise true/false values
gem 'humanize_boolean', '~> 0.0.2'
# Calendar
gem "simple_calendar", "~> 2.0"
# Asset pipeline
gem 'bootstrap', '~> 4.1.3'
gem 'jquery-rails'
gem 'momentjs-rails'
gem 'bootstrap4-datetime-picker-rails'
gem "font-awesome-rails"
# View rendering
gem 'haml'
gem 'kramdown'
# GDPR
gem 'cookies_eu'
# Camdram API wrapper
#gem 'camdram', '~> 1.1'
gem 'camdram', :git => 'https://github.com/CHTJonas/camdram-ruby.git'
# Authorisation library
gem 'cancancan', '~> 2.0'
# Error tracking and reporting
gem 'sentry-raven'
# Markdown for emails
gem 'maildown'
# DDoS protection and IP blocking
gem 'rack-attack', '~> 5.4', '>= 5.4.2'
# User Gravatar profile pictures
gem 'gravatar_image_tag', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  gem 'sqlite3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :deployment do
  gem 'pg'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
