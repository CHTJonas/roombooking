threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
workers_count = ENV.fetch('WEB_CONCURRENCY') { 3 }

threads threads_count, threads_count
workers workers_count

environment = ENV.fetch('RAILS_ENV') { 'development' }
environment environment

if environment == 'production' || ENV['BIND']
  # If we prune the bundler context in development then we lose Rails' logging to STDOUT.
  prune_bundler
  bind 'unix:///var/run/roombooking/app_serv.sock?umask=0077'
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# We don't need to worry about ActiveRecord since we're not preloading.
before_fork do
  # ActiveRecord::Base.connection_pool.disconnect!
end
on_worker_boot do
  # ActiveSupport.on_load(:active_record) do
  #   ActiveRecord::Base.establish_connection
  # end
end
