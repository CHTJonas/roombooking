class BookingsController < ApplicationController

  def index
    @bookings = Booking.accessible_by(current_ability, :read).last(6)
  end

  def new
    authorize! :create, Booking
    @booking = Booking.new
    @shows = current_user.authorised_camdram_shows
    @societies = current_user.authorised_camdram_societies
  end

  def edit
    @booking = Booking.find(params[:id])
    @shows = current_user.authorised_camdram_shows
    @societies = current_user.authorised_camdram_societies
    authorize! :edit, @booking
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id
    if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
      @booking.camdram_id = nil
    else
      @booking.camdram_id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
    end
    unless validate_booking_against_camdram(@booking)
      alert = { 'class' => 'danger', 'message' => "You need to be a Camdram admin of a booking's show/society in order to edit it." }
      flash.now[:alert] = alert
      render :new and return
    end
    authorize! :create, @booking
    if @booking.save
      alert = { 'class' => 'success', 'message' => "Added #{@booking.name}!" }
      flash[:alert] = alert
      redirect_to @booking
    else
      alert = { 'class' => 'danger', 'message' => @booking.errors.full_messages.first }
      flash.now[:alert] = alert
      render :new
    end
  end

  def update
    @booking = Booking.find(params[:id])
    if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
      @booking.camdram_id = nil
    else
      @booking.camdram_id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
    end
    unless validate_booking_against_camdram(@booking)
      alert = { 'class' => 'danger', 'message' => "You need to be a Camdram admin of a booking's show/society in order to edit it." }
      flash.now[:alert] = alert
      render :edit and return
    end
    authorize! :edit, @booking
    if @booking.update(booking_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@booking.name}!"}
      flash[:alert] = alert
      redirect_to @booking
    else
      alert = { 'class' => 'danger', 'message' => @booking.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  def show
    @booking = Booking.find(params[:id])
    authorize! :read, @booking
  end

  def destroy
    @booking = Booking.find(params[:id])
    authorize! :destroy, @booking
    @booking.destroy
    alert = { 'class' => 'success', 'message' => "Deleted #{@booking.name}!"}
    flash[:alert] = alert
    redirect_to bookings_path
  end

  private

  def booking_params
    params.require(:booking).permit(:name, :notes, :when, :length, :venue_id, :purpose)
  end

  def validate_booking_against_camdram(booking)
    if Booking.admin_purposes.find_index(booking.purpose.to_sym) && !current_user.admin?
      return false
    end
    if Booking.purposes_with_shows.find_index(booking.purpose.to_sym)
      return current_user.authorised_camdram_shows.map { |e| e[1] }.include? booking.camdram_id
    elsif Booking.purposes_with_societies.find_index(booking.purpose.to_sym)
      return current_user.authorised_camdram_societies.map { |e| e[1] }.include? booking.camdram_id
    elsif Booking.purposes_with_none.find_index(booking.purpose.to_sym)
      return true
    else
      return false
    end
  end
end
