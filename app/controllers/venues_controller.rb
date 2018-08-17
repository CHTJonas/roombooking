class VenuesController < ApplicationController
  def index
    @venues = Venue.all
  end

  def new
    @venue = Venue.new
  end

  def edit
    @venue = Venue.find(params[:id])
  end

  def create
    @venue = Venue.new(venue_params)
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
    @bookings = @venue.booking
  end

  def destroy
    @venue = Venue.find(params[:id])
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
