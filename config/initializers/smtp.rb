# frozen_string_literal: true

if ENV['SMTP_HOST'].nil?
  ActionMailer::Base.delivery_method = :sendmail
else
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address                => ENV['SMTP_HOST'],
    :port                   => ENV['SMTP_PORT'],
    :user_name              => ENV['SMTP_USER'],
    :password               => ENV['SMTP_PASS'],
    :authentication         => ENV['SMTP_AUTH'],
    :enable_starttls_auto   => ENV['SMTP_STARTTLS'] == '1'
  }
end
