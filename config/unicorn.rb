worker_processes ENV.fetch("WEB_CONCURRENCY") { "1" }.to_i
working_directory ENV['APP_ROOT'] if ENV['APP_ROOT']
listen ENV.fetch("IP") { "127.0.0.1" } + ":" + ENV.fetch("PORT") { "8080" }, :tcp_nopush => true
timeout 5
preload_app true
check_client_connection false

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
