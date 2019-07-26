# frozen_string_literal: true

sidekiq_url = ENV['REDIS_STORE'].freeze

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url }
  schedule_file = Rails.root.join('config', 'schedule.yml')
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url }
end

Sidekiq::Throttled.setup!
