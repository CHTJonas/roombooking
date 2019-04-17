# frozen_string_literal: true

Devise.setup do |config|
  require 'devise/orm/active_record'

  # Mailer Configuration
  config.mailer_sender = 'noreply@adctheatre.com'

  # Configuration for any authentication mechanism
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.params_authenticatable = false
  config.http_authenticatable_on_xhr = true
  config.clean_up_csrf_token_on_authentication = true

  # Configuration for :confirmable
  config.allow_unconfirmed_access_for = 0.days
  config.confirm_within = 1.hour
  config.reconfirmable = true
  config.confirmation_keys = [:email]

  # Configuration for :omniauthable
  config.omniauth :camdram, ENV['CAMDRAM_APP_ID'], ENV['CAMDRAM_APP_SECRET'], scope: 'user_shows user_orgs user_email'

  # Configuration for :timeoutable
  config.timeout_in = 2.weeks

  # The HTTP method used to sign out a resource.
  config.sign_out_via = :delete

end
