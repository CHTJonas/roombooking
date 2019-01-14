Rails.application.config.middleware.use OmniAuth::Builder do
  id = Rails.application.credentials.dig(:camdram, :app_id)
  secret = Rails.application.credentials.dig(:camdram, :app_secret)
  provider :camdram, id, secret, scope: "user_shows user_orgs user_email"
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
