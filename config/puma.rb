# frozen_string_literal: true

require_relative 'prod'

rails_environment = ENV.fetch('RAILS_ENV') { 'development' }
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
workers_count = ENV.fetch('WEB_CONCURRENCY') { 1 }

environment rails_environment
threads threads_count, threads_count
workers workers_count

if rails_environment == 'production'
  port 8080
  worker_timeout 15
  worker_boot_timeout 15
  worker_shutdown_timeout 15
end

if ENV['ENABLE_PROMETHEUS'] == '1'
  on_worker_boot do
    require 'prometheus_exporter/instrumentation'
    PrometheusExporter::Instrumentation::Process.start(type: 'puma')
    PrometheusExporter::Instrumentation::ActiveRecord.start(
      custom_labels: { type: 'puma' },
      config_labels: [:database, :host]
    )
  end

  after_worker_boot do
    require 'prometheus_exporter/instrumentation'
    PrometheusExporter::Instrumentation::Puma.start
  end

  on_worker_shutdown do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end
end
