# frozen_string_literal: true

require 'ddtrace'

if ENV['ENABLE_DATADOG_APM']
  Datadog.configure do |c|
    c.use :rails
    c.use :rake
    c.use :sidekiq, service_name: 'sidekiq-server'
  end
end
