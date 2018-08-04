class BookingsController < ApplicationController
  before_action :authenticate_user!, :except => [:index, :show]
  before_action :correct_user, :except => [:index, :show]

  def index
    @bookings = Booking.all
  end

  def new
    @booking = Booking.new
  end

  def edit
    @booking = Booking.find(params[:id])
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id
    if @booking.save
      alert = { 'class' => 'success', 'message' => "Added #{@booking.name}!" }
      flash[:alert] = alert
      redirect_to @booking
    else
      alert = { 'class' => 'danger', 'message' => @booking.errors.full_messages.first }
      flash.now[:alert] = alert
      render 'new'
    end
  end

  def update
    @booking = Booking.find(params[:id])
    if @booking.update(booking_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@booking.name}!"}
      flash[:alert] = alert
      redirect_to @booking
    else
      alert = { 'class' => 'danger', 'message' => @booking.errors.full_messages.first }
      flash.now[:alert] = alert
      render 'edit'
    end
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    alert = { 'class' => 'success', 'message' => "Deleted #{@booking.name}!"}
    flash[:alert] = alert
    redirect_to bookings_path
  end

  private

    def booking_params
      params.require(:booking).permit(:name, :notes, :when, :length, :venue_id)
    end

    # Checks if the user is accessing one of their own bookings
    def correct_user
      check_user Booking.find(params[:id]).user
    end
end
