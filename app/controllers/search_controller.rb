class SearchController < ApplicationController
  def search_for_bookings
    query = params['q']
    page = params[:page]
    @bookings = Booking.order(created_at: :desc).accessible_by(current_ability, :read).search_by_name_and_notes(query).page(page)
  end

  def search_for_users
    query = params['q']
    page = params[:page]
    @users = User.search_by_name_and_email(query).page(page)
  end
end
