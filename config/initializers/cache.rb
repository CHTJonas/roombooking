# frozen_string_literal: true

# We have to configure this here because our middleware classes
# aren't loaded in time for it to be in environments/production.rb.
if Rails.env.production?
  Rails.application.config.middleware.insert_before ActionDispatch::Static, Roombooking::Middleware::PublicCacheManager
end

# Serve static assets using the public file server as NGINX only
# handles TLS termination. Also configure the Cache-Control
# header for increased performance.
Rails.application.config.public_file_server.enabled = true
Rails.application.config.public_file_server.headers = {
  'Cache-Control' => "public, max-age=#{1.year.to_i}, immutable"
} if Rails.env.production? || Rails.env.test?
