class VenuesController < ApplicationController
  helper_method :events_for

  def index
    @venues = Venue.accessible_by(current_ability, :read)
  end

  def new
    authorize! :create, Venue
    @venue = Venue.new
  end

  def edit
    @venue = Venue.find(params[:id])
    authorize! :edit, @venue
  end

  def create
    @venue = Venue.new(venue_params)
    authorize! :create, @venue
    if @venue.save
      alert = { 'class' => 'success', 'message' => "Added #{@venue.name}!" }
      flash[:alert] = alert
      redirect_to @venue
    else
      alert = { 'class' => 'danger', 'message' => @venue.errors.full_messages.first }
      flash.now[:alert] = alert
      render :new
    end
  end

  def update
    @venue = Venue.find(params[:id])
    authorize! :edit, @venue
    if @venue.update(venue_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@venue.name}!"}
      flash[:alert] = alert
      redirect_to @venue
    else
      alert = { 'class' => 'danger', 'message' => @venue.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  def show
    @venue = Venue.find(params[:id])
    authorize! :read, @venue
  end

  def destroy
    @venue = Venue.find(params[:id])
    authorize! :destroy, @venue
    @venue.destroy
    alert = { 'class' => 'success', 'message' => "Deleted #{@venue.name}!"}
    flash[:alert] = alert
    redirect_to venues_path
  end

  protected

  def events_for(venue)
    start_date = (params[:start_date] ? Date.parse(params[:start_date]) : Date.today).beginning_of_week
    end_date = start_date + 7.days

    daily_bookings = venue.booking.where(repeat_mode: :none)
                                  .where(start_time: start_date..end_date)
                                  .accessible_by(current_ability, :read)
    daily_events = Array.new(daily_bookings.length)
    daily_bookings.to_a.each_with_index { |val, index| daily_events[index] = Event.create_from_booking(val) }

    repeat_events = LinkedList::List.new

    daily_repeat_bookings = venue.booking.where(repeat_mode: :daily)
                                         .where(start_time: Time.at(0)..end_date)
                                         .where(repeat_until: start_date..DateTime::Infinity.new)
                                         .accessible_by(current_ability, :read)
    daily_repeat_bookings.to_a.each do |booking|
      (booking.start_time.to_date..booking.repeat_until).each do |date|
        break if date > end_date
        offset = date - booking.start_time.to_date
        repeat_events.push Event.create_from_booking(booking, offset)
      end
    end

    weekly_repeat_bookings = venue.booking.where(repeat_mode: :weekly)
                                          .where(start_time: Time.at(0)..end_date)
                                          .where(repeat_until: start_date..DateTime::Infinity.new)
                                          .accessible_by(current_ability, :read)
    weekly_repeat_bookings.to_a.each do |booking|
      offset = start_date - booking.start_time.to_date.beginning_of_week
      repeat_events.push Event.create_from_booking(booking, offset)
    end

    daily_events + repeat_events.to_a
  end

  private

  def venue_params
    params.require(:venue).permit(:name)
  end
end
