worker_processes ENV.fetch("WEB_CONCURRENCY") { "1" }.to_i
working_directory ENV['APP_ROOT'] if ENV['APP_ROOT']

# By default we bind to a Unix socket
listen ENV['APP_ROOT'] + '/tmp/pids/unicorn.sock', :backlog => 2048

# But you can uncomment this if you want to bind to a TCP port
#listen ENV.fetch("IP") { "127.0.0.1" } + ":" + ENV.fetch("PORT") { "8080" }, :tcp_nopush => true

# Note: this is unicorn's own pid file that's seperate from Procodile's
# It's so that we can do zero-downtime restarts properly
pid ENV['APP_ROOT'] + '/tmp/pids/unicorn.pidfile'

timeout 5
preload_app true
check_client_connection false

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  old_pid_file = ENV['APP_ROOT'] + '/tmp/pids/unicorn.pidfile.oldbin'
  if File.exists?(old_pid_file) && server.pid != old_pid_file
    begin
      Process.kill("QUIT", File.read(old_pid_file).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # Someone else did the job for us!
    ensure
      # Update procodile's own seperate pid file
      File.write(ENV['PID_FILE'], File.read(server.pid))
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
