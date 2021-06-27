# frozen_string_literal: true

# We have to configure this here because our middleware classes
# aren't loaded in time for this to be in environments/production.rb.
if Rails.env.production?
  Rails.application.config.middleware.insert_before ActionDispatch::Static, Roombooking::Middleware::PublicCacheManager
  Rails.application.config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}, immutable"
  }
end
