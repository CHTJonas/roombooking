# frozen_string_literal: true

sidekiq_url = ENV['REDIS_STORE'].freeze

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url }
  schedule_file = Rails.root.join('config', 'schedule.yml')
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)

  if ENV['ENABLE_PROMETHEUS'] == '1'
    config.on :startup do
      require 'prometheus_exporter/instrumentation'
      PrometheusExporter::Instrumentation::Process.start(type: 'sidekiq')
      PrometheusExporter::Instrumentation::ActiveRecord.start(
        custom_labels: { type: "sidekiq" },
        config_labels: [:database, :host]
      )
    end

    config.server_middleware do |chain|
      require 'prometheus_exporter/instrumentation'
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end
    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    at_exit do
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url }
end

Sidekiq::Throttled.setup!
