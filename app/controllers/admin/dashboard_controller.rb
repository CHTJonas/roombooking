module Admin
  class DashboardController < ApplicationController
    # This method should never be needed as routes are constrained by
    # Roombooking::AdminConstraint however it's included just to be safe.
    before_action :must_be_admin!
  end
end
