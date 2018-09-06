class VenuesController < ApplicationController

  def index
    @venues = Venue.accessible_by(current_ability, :read)
  end

  def new
    @venue = Venue.new
    authorize! :create, @venue
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
    @bookings = @venue.booking.accessible_by(current_ability, :read)
  end

  def destroy
    @venue = Venue.find(params[:id])
    authorize! :destroy, @venue
    @venue.destroy
    alert = { 'class' => 'success', 'message' => "Deleted #{@venue.name}!"}
    flash[:alert] = alert
    redirect_to venues_path
  end

  private

  def venue_params
    params.require(:venue).permit(:name)
  end
end
