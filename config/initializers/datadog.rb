require 'ddtrace'

Datadog.configure do |c|
  c.use :rails
  c.use :rake
  c.use :sidekiq, service_name: 'sidekiq-server'
end
