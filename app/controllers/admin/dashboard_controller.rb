module Admin
  class DashboardController < ApplicationController
    before_action :must_be_admin!

    private

    def must_be_admin!
      unless user_is_admin?
        # This method should never be needed as routes are constrained by
        # Roombooking::AdminConstraint however it's included just to be safe.
        alert = { 'class' => 'danger', 'message' => "Acess denied — you don't appear to be an administrator!" }
        flash.now[:alert] = alert
        render 'layouts/blank', locals: {reason: 'user not admin'}, status: :forbidden and return
      end
    end
  end
end
