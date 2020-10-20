source 'https://rubygems.org'

ruby '2.6.6'

# Application config
gem 'dotenv-rails', '~> 2.7'

# Rails
gem 'rails', '~> 6.0.3'
gem 'puma', '~> 5.0'
gem 'rack-timeout', '~> 0.6.0'
gem 'sassc', '~> 2.4'
gem 'sass-rails', '~> 6.0'
gem 'webpacker', '~> 5.2'
gem 'linked-list', '~> 0.0.15'

# Audit model changes
gem 'paper_trail', '~> 11.0'
gem 'paper_trail-association_tracking', '~> 2.1'
# Encrypt sensitive model attributes
gem 'attr_encrypted', '~> 3.1'
# Remove whitespace from model attributes
gem 'strip_attributes', '~> 1.11'
# HTTP security headers
gem 'secure_headers', '~> 6.3'
# Administrator interface
gem 'rails_admin', '~> 2.0'
gem 'rails_admin_history_rollback', '~> 1.0'
gem 'gemsurance', '~> 0.10.0'
# Background job processing
gem 'sidekiq', '~> 6.1'
gem 'sidekiq-cron', '~> 1.2'
gem 'sidekiq-throttled', '~> 0.13.0'
gem 'sidekiq_queue_metrics', '~> 3.0'
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
gem 'kaminari', '~> 1.2'
# Calendar
gem 'simple_calendar', '~> 2.4'
gem 'icalendar', '~> 2.7'
# View rendering
gem 'haml', '~> 5.2'
gem 'kramdown', require: false
gem 'redcarpet', '~> 3.5'
# Inline email styles
gem 'premailer-rails', '~> 1.11'
# GDPR
gem 'cookies_eu'
# Detection of server platofrm and client browser
gem 'os', '~> 1.1'
gem 'browser', '~> 5.1'
# Connection pooling
gem 'connection_pool', '~> 2.2'
# Camdram API wrapper
gem 'camdram', git: 'https://github.com/CHTJonas/camdram-ruby.git', require: 'camdram/client'
gem 'faraday_middleware', '~> 1.0.0'
# Authentication
gem 'omniauth-camdram', '~> 1.0'
gem 'omniauth-rails_csrf_protection', '~> 0.1.2'
gem 'rotp', '~> 6.2'
gem 'rqrcode', '~> 1.1.2'
gem 'recaptcha', '~> 5.6'
# Authorisation
gem 'cancancan', '~> 3.1'
# Error tracking and reporting
gem 'sentry-raven', '~> 3.1'
# DDoS protection and IP blocking
gem 'rack-attack', '~> 6.3'
# User Gravatar profile pictures
gem 'gravatar_image_tag', '~> 1.2'
# Colour text for ANSI terminals
gem 'rainbow', '~> 3.0'
# Use pry console
gem 'pry-rails', '~> 0.3.9'
# Push notifications
gem 'slack-notifier', '~> 2.3'
# Sitemaps
gem 'sitemap_generator', '~> 6.1'

# Database persistence
gem 'pg', '~> 1.2'
gem 'pg_search', '~> 2.3'

# Key/value caching
gem 'redis', '~> 4.2'
gem 'hiredis', '~> 0.6.3'

# Metrics & Logging
gem 'prometheus_exporter', '~> 0.5.3'
gem 'ddtrace', '~> 0.41.0'
gem 'yell', '~> 2.2'
gem 'lograge', '~> 0.11.2'
gem 'health_check', '~> 3.0'

# Reverse proxy
gem 'rack-reverse-proxy', '~> 0.12.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Performance improvements using native extensions
gem 'escape_utils', '~> 1.2'
gem 'fast_blank', '~> 1.0'
gem 'oj', '~> 3.10'

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
  gem 'listen', '>= 3.0.5', '< 3.3'
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
  gem 'webdrivers', '~> 4.4'
  gem 'minitest-retry', '~> 0.2.1', require: false
  gem 'codecov', '~> 0.2.12', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
