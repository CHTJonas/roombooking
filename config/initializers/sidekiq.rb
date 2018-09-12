Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials.dig(:redis, :persistent_url) }
  config.error_handlers << Proc.new {|ex,ctx_hash| Raven.capture_exception(ex, level: 'warning') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials.dig(:redis, :persistent_url) }
end
