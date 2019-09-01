# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environments = ['production', 'development']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.sanitize_fields += ['_roombooking_session']
  config.processors -= [Raven::Processor::PostData] # Do this to send POST data
  config.processors -= [Raven::Processor::Cookies] # Do this to send cookies
  config.release = Roombooking::Version.to_s
  config.silence_ready = true
  config.async = lambda do |event|
    SentryJob.perform_async(event)
  end
end
