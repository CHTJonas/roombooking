class BookingsController < ApplicationController

  def index
    @bookings = Booking.accessible_by(current_ability, :read).last(6)
  end

  def new
    @booking = Booking.new
    authorize! :create, @booking
    enumerate_camdram
  end

  def edit
    @booking = Booking.find(params[:id])
    authorize! :edit, @booking
  end

  def create
    @booking = Booking.new(booking_params)
    authorize! :create, @booking
    unless Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
      @booking.camdram_object_id = params[:booking]["camdram_object_id_#{@booking.purpose}".to_sym]
    end
    @booking.user_id = current_user.id
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

  def enumerate_camdram
    @shows = Array.new
    shows = case user_is_admin?
      when false
        # Users can make bookings on behalf of shows they admin on Camdram
        # TODO remove non ADC shows and include corpus shows and bar shows
        camdram.user.get_shows
      when true
        # Admins can make bookings on behalf of any upcoming shows
        # TODO include corpus shows and bar shows
        camdram.get_venue('adc-theatre').shows
    end
    shows.each do |show|
      if show.performances.last.end_date > Time.now
        cdobj = CamdramObject.where(ref_type: 'show', camdram_id: show.id)
        if cdobj.empty?
          @shows << CamdramObject.create_from_show(show)
        else
          @shows << cdobj.first
        end
      end
    end
    @societies = Array.new
    societies = case user_is_admin?
      when false
        # Users can make bookings on behalf of societies they admin on Camdram
        camdram.user.get_orgs
      when true
        # Admins can make bookings on behalf of any societies
        camdram.get_orgs
    end
    societies.each do |society|
      cdobj = CamdramObject.where(ref_type: 'society', camdram_id: society.id)
      if cdobj.empty?
        @societies << CamdramObject.create_from_society(society)
      else
        @societies << cdobj.first
      end
    end
    # if @camdram_objects.blank?
    #   alert = { 'class' => 'danger', 'message' => 'You must be listed as a Camdram admin for a society or upcoming show in order to make bookings.' }
    #   flash.now[:alert] = alert
    #   render 'layouts/blank', locals: {reason: 'camdram_objects array is blank'}, status: :forbidden
    # end
  end
end
