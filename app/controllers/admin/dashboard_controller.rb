module Admin
  class DashboardController < ApplicationController
    # This method should never be needed as routes are constrained by
    # Roombooking::AdminConstraint however it's included just to be safe.
    before_action :must_be_admin!

    def backup
      begin
        send_data `pg_dump -Fc roombooking_#{Rails.env}`,
          filename: "roombooking_#{Rails.env}_#{DateTime.now.to_i}.pgdump"
      rescue
        render plain: "An error occurred when creating the backup!"
      end
    end
  end
end
