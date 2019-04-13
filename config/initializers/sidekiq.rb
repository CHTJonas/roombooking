# frozen_string_literal: true

sidekiq_url = ENV['REDIS_STORE']

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url }
  config.error_handlers << Proc.new  do |exception, context_hash|
    Raven.capture_exception(exception, level: 'warning')
  end

  schedule_file = Rails.root.join('config/schedule.yml')
  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url }
end
