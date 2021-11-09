# frozen_string_literal: true

require 'roombooking/host'

config = Rails.application.config

Yell['mail'] = Yell.new do |l|
  mail_log_file = Rails.root.join('log', "roombooking_#{Rails.env}_mail.log")
  l.adapter(:datefile, mail_log_file, keep: 31, level: 'gte.info')
end
config.action_mailer.logger = Yell['mail']

if Rails.env.development?
  config.action_mailer.default_url_options = {
    host: '127.0.0.1',
    port: ENV.fetch("PORT") { 3000 }
  }
else
  config.action_mailer.default_url_options = {
    host: Roombooking::Host.name,
    protocol: 'https'
  }
end

if ENV['SMTP_HOST'].nil?
  config.action_mailer.delivery_method = :sendmail
else
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address                => ENV['SMTP_HOST'],
    :port                   => ENV['SMTP_PORT'],
    :user_name              => ENV['SMTP_USER'],
    :password               => ENV['SMTP_PASS'],
    :authentication         => ENV['SMTP_AUTH'],
    :enable_starttls_auto   => ENV['SMTP_STARTTLS'] == '1'
  }
end

ActionMailer::Base.register_observer(Class.new do
  def self.delivered_email(message)
    Email.create_from_message(message)
    Yell['mail'].info("Message-ID:#{message.message_id} From:#{message.from[0]} To:#{message.to[0]} Subject:#{message.subject}")
  end
end)
