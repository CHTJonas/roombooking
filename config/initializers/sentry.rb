# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.release = Roombooking::Version.git_description
  config.enabled_environments = ['production', 'development']
  config.async = lambda do |event, hint|
    SentryJob.perform_async(event, hint)
  end
end
