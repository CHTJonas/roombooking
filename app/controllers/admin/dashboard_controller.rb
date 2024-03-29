# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    before_action :must_be_admin!

    def info
      render html: Rails::Info.to_html.html_safe
    end

    def restart
      log_abuse "#{current_user.to_log_s} initiated a system restart"
      if Rails.env.production?
        `/usr/bin/sudo /bin/systemctl restart roombooking.target`
      else
        render plain: 'No restart handler available; refusing to do so.'
      end
    end

    def shutdown
      log_abuse "#{current_user.to_log_s} initiated a system shutdown"
      if Rails.env.production?
        `/usr/bin/sudo /bin/systemctl stop roombooking.target`
      else
        render plain: 'No shutdown handler available; refusing to do so.'
      end
    end

    def backup
      log_abuse "#{current_user.to_log_s} downloaded a database dump"
      begin
        send_data `pg_dump -Fc roombooking_#{Rails.env}`,
          filename: "roombooking_#{Rails.env}_#{Time.zone.now.to_i}.pgdump"
      rescue StandardError => e
        Sentry.capture_exception(e)
        render plain: 'An error occurred when creating the backup!'
      end
    end
  end
end
