Rails.application.config.middleware.use OmniAuth::Builder do
  provider :camdram, ENV['CAMDRAM_APP_ID'], ENV['CAMDRAM_APP_SECRET'], scope: "user_shows user_orgs user_email"
end
