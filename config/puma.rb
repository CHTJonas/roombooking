# frozen_string_literal: true

threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
workers_count = ENV.fetch('WEB_CONCURRENCY') { 1 }

threads threads_count, threads_count
workers workers_count

if File.exist? File.expand_path('../.prod', __dir__)
  ENV['RAILS_ENV'] = 'production'
end
environment = ENV.fetch('RAILS_ENV') { 'development' }
environment environment

if environment == 'production'
  # If we prune the bundler context in development then we lose Rails' logging to STDOUT.
  prune_bundler
  port 8080

  worker_timeout 15
  worker_boot_timeout 15
  worker_shutdown_timeout 15
end

# We don't need to worry about ActiveRecord since we're not preloading.
before_fork do
  # ActiveRecord::Base.connection_pool.disconnect!
end
on_worker_boot do
  # ActiveSupport.on_load(:active_record) do
  #   ActiveRecord::Base.establish_connection
  # end
end
