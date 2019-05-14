source 'https://rubygems.org'

ruby '2.6.3'

gem 'rails', '~> 5.2.2'
gem 'puma', '~> 3.12'
gem 'rack-timeout', '~> 0.5.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'linked-list', '~> 0.0.13'
gem 'redis', '~> 4.1'

# Audit model changes
gem 'paper_trail', '~> 10.3'
gem 'paper_trail-association_tracking', '~> 2.0'
# Encrypt sensitive model attributes
gem 'attr_encrypted', '~> 3.1'
# HTTP security headers
gem 'secure_headers', '~> 6.1'
# Administrator interface
gem 'rails_admin', '~> 1.3'
gem 'rails_admin_history_rollback', '~> 1.0'
# Background job processing
gem 'sidekiq', '~> 5.2'
gem 'sidekiq-cron', '~> 1.1'
gem 'sidekiq-throttled', '~> 0.9.0'
# Static page serving
gem 'high_voltage', '~> 3.1'
# Date/time handling
gem 'chronic', '~> 0.10.2'
gem 'chronic_duration', '~> 0.10.6'
gem 'datey', '~> 1.1'
# Humanise some common data types
gem 'humanize_boolean', '~> 0.0.2'
gem 'possessive', '~> 1.0'
# Pagination
gem 'kaminari', '~> 1.1'
# Controller wizzards
gem 'wicked', '~> 1.3'
# Calendar
gem 'simple_calendar', '~> 2.0'
gem 'icalendar', '~> 2.5'
# Asset pipeline
gem 'bootstrap', '~> 4.3'
gem 'jquery-rails', '~> 4.3'
gem 'flatpickr', '~> 4.5'
gem 'font-awesome-rails', '~> 4.7'
# View rendering
gem 'haml', '~> 5.0'
gem 'kramdown', require: false
gem 'redcarpet', '~> 3.4'
# GDPR
gem 'cookies_eu'
# Detection of server platofrm and client browser
gem 'os', '~> 1.0'
gem 'browser', '~> 2.5'
# Connection pooling
gem 'connection_pool', '~> 2.2', '>= 2.2.2'
# Camdram API wrapper
gem 'camdram', git: 'https://github.com/CHTJonas/camdram-ruby.git'
gem 'faraday_middleware', '~> 0.13.0'
# Authentication
gem 'omniauth-camdram', '~> 1.0'
gem 'rotp', '~> 4.1'
gem 'rqrcode', '~> 0.10.1'
# Authorisation
gem 'cancancan', '~> 3.0'
# Error tracking and reporting
gem 'sentry-raven', '~> 2.9'
# Markdown for emails
gem 'maildown', '~> 3.0'
# DDoS protection and IP blocking
gem 'rack-attack', '~> 6.0'
# User Gravatar profile pictures
gem 'gravatar_image_tag', '~> 1.2'
# Colour text for ANSI terminals
gem 'rainbow', '~> 3.0'
# Use pry console
gem 'pry-rails', '~> 0.3.9'
# Push notifications
gem 'slack-notifier', '~> 2.3'
# Sitemaps
gem 'sitemap_generator', '~> 6.0'
# Ruby variables in JS
gem 'gon', '~> 6.2'

# Application config
gem 'dotenv-rails', '~> 2.7'

# Database persistence
gem 'pg', '~> 1.1'
gem 'pg_search', '~> 2.1'

# Performance profiling bar
gem 'peek', '~> 1.0'
gem 'peek-git', '~> 1.0'
gem 'peek-performance_bar', '~> 1.3'
gem 'peek-pg', '~> 1.3'
gem 'peek-redis', '~> 1.2'
gem 'peek-sidekiq', '~> 1.0'
gem 'peek-gc', '~> 0.0.2'
gem 'peek-rblineprof', '~> 0.2.0'

# Metrics & Logging
gem 'ddtrace', '~> 0.23.2'
gem 'yell', '~> 2.0'
gem 'lograge', '~> 0.10.0'
gem 'health_check', '~> 3.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Performance improvements using native extensions
gem 'escape_utils', '~> 1.2'
gem 'fast_blank', '~> 1.0'
gem 'oj', '~> 3.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Improve upon Rails' default exception pages
  gem 'better_errors'
  gem 'binding_of_caller'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Help avoid N+1 queries
  gem 'bullet'
  # Annotate models
  gem 'annotate'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'selenium-webdriver', '~> 3.142'
  gem 'webdrivers', '~> 3.9'
  gem 'codecov', '~> 0.1.14', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
