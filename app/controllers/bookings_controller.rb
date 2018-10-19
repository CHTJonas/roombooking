class BookingsController < ApplicationController

  def index
    @bookings = Booking.accessible_by(current_ability, :read).last(6)
  end

  def new
    authorize! :create, Booking
    @booking = Booking.new
    populate_camdram
  end

  def edit
    @booking = Booking.find(params[:id])
    populate_camdram
    authorize! :edit, @booking
  end

  def create
    @booking = Booking.new(booking_params)
    populate_camdram
    @booking.approved = user_is_admin?
    @booking.user_id = current_user.id
    unless @booking.purpose.nil?
      if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
        @booking.camdram_id = nil
      else
        @booking.camdram_id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
      end
    end
    unless authorise_booking_against_camdram(@booking)
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
      flash.now[:alert] = alert
      render :new and return
    end
    authorize! :create, @booking
    if @booking.save
      notify_admins
      alert = { 'class' => 'success', 'message' => "Added #{@booking.name}! You will need to wait for this booking to be approved by an admin before it is shown publicly." }
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
    populate_camdram
    unless @booking.purpose.nil?
      if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
        @booking.camdram_id = nil
      else
        @booking.camdram_id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
      end
    end
    unless authorise_booking_against_camdram(@booking)
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
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
    alert = { 'class' => 'success', 'message' => "Deleted #{@booking.name}!" }
    flash[:alert] = alert
    redirect_to bookings_path
  end

  def approve
    @booking = Booking.find(params[:id])
    authorize! :approve, @booking
    @booking.approved = true
    if @booking.save
      ApprovalsMailer.approve(@booking.user, @booking).deliver_later
      alert = { 'class' => 'success', 'message' => "Approved #{@booking.name}!" }
      flash[:alert] = alert
      redirect_to @booking
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:name, :notes, :start_time, :length, :venue_id, :purpose)
  end

  def populate_camdram
    @shows = current_user.authorised_camdram_shows
    @societies = current_user.authorised_camdram_societies
  end

  def authorise_booking_against_camdram(booking)
    return true if booking.purpose.nil? # can't authorise if there's no purpose given (get's caught by validation in model)
    if Booking.admin_purposes.find_index(booking.purpose.to_sym)
      return current_user.admin?
    end
    if Booking.purposes_with_none.find_index(booking.purpose.to_sym)
      return true
    end
    return true if params[:booking]["camdram_id_#{@booking.purpose}".to_sym].nil? # can't authorise if there's no show/society selected (get's caught by validation in model)
    if Booking.purposes_with_shows.find_index(booking.purpose.to_sym)
      return current_user.authorised_camdram_shows.map { |e| e[1] }.include? booking.camdram_id
    elsif Booking.purposes_with_societies.find_index(booking.purpose.to_sym)
      return current_user.authorised_camdram_societies.map { |e| e[1] }.include? booking.camdram_id
    else
      return false
    end
  end

  def notify_admins
    User.where(admin: true).find_each(batch_size: 2) do |user|
      ApprovalsMailer.notify(user, @booking).deliver_later
    end unless @booking.approved
  end
end
