Raven.configure do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.sanitize_fields += ['_roombooking_session']
  config.processors -= [Raven::Processor::PostData] # Do this to send POST data
  config.processors -= [Raven::Processor::Cookies] # Do this to send cookies
  config.release = Roombooking::VERSION
end if Rails.env.production?
