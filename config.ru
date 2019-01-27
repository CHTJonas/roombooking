# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# Warm up the app by sending a few mock requests to expensive endpoints
# so that it's speedy for the first real request.
warmup do |app|
  client = Rack::MockRequest.new(app)
  client.get('/')
  client.get('/rooms.ics')
end

run Rails.application
