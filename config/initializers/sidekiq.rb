# frozen_string_literal: true

sidekiq_url = case ENV['REDIS_URL'].present?
when true
  sidekiq_url = ENV['REDIS_URL']
else
  sidekiq_url = Rails.application.credentials.dig(:redis, :persistent_url)
end

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url }
  config.error_handlers << Proc.new {|ex,ctx_hash| Raven.capture_exception(ex, level: 'warning') }

  schedule_file = "config/schedule.yml"

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url }
end
