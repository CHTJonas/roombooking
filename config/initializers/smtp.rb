# frozen_string_literal: true

if Rails.application.credentials.dig(:smtp, :host)
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address                => Rails.application.credentials.dig(:smtp, :host),
    :port                   => Rails.application.credentials.dig(:smtp, :port),
    :user_name              => Rails.application.credentials.dig(:smtp, :username),
    :password               => Rails.application.credentials.dig(:smtp, :password),
    :authentication         => Rails.application.credentials.dig(:smtp, :auth),
    :enable_starttls_auto   => Rails.application.credentials.dig(:smtp, :starttls) == '1'
  }
else
  ActionMailer::Base.delivery_method = :sendmail
end
