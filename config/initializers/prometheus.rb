# frozen_string_literal: true

unless Rails.env.test?
  require 'rack/reverse_proxy'
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'
  PrometheusExporter::Instrumentation::Process.start(type: 'rails')
  Rails.application.middleware.unshift PrometheusExporter::Middleware
  Rails.application.middleware.insert(0, Rack::ReverseProxy) do
    reverse_proxy_options preserve_host: false
    reverse_proxy '/metrics', 'http://localhost:9394/metrics'
  end
end
