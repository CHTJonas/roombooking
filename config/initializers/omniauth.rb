# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  id = ENV['CAMDRAM_APP_ID']
  secret = ENV['CAMDRAM_APP_SECRET']
  provider :camdram, id, secret, scope: 'user_shows user_orgs user_email'
end

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
