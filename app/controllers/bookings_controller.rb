class BookingsController < ApplicationController

  def index
    @bookings = Booking.order(created_at: :desc)
      .eager_load(:user, :room)
      .accessible_by(current_ability, :read)
      .page(params[:page]).without_count
  end

  def new
    authorize! :create, Booking
    @booking = Booking.new
    populate_from_camdram
  end

  def edit
    @booking = Booking.find(params[:id])
    populate_from_camdram
    authorize! :edit, @booking
  end

  def create
    @booking = Booking.new(booking_params)
    populate_from_camdram
    @booking.approved = user_is_admin? || ApplicationSetting.instance.auto_approve_bookings?
    @booking.user_id = current_user.id
    setup_booking_purpose
    unless authorise_booking_against_camdram
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
      flash.now[:alert] = alert
      render :new and return
    end
    authorize! :create, @booking
    if @booking.save
      notify_admins
      msg = "Added #{@booking.name}!"
      msg << " You will need to wait for this booking to be approved by an admin before it is shown publicly." unless @booking.approved?
      alert = { 'class' => 'success', 'message' =>  msg}
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
    populate_from_camdram
    setup_booking_purpose
    unless authorise_booking_against_camdram
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
    @booking = Booking.eager_load(:user, :room).find(params[:id])
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
    if user_is_admin?
      params.require(:booking).permit(:name, :notes, :start_time, :length, :room_id, :purpose, :repeat_mode, :repeat_until, :approved)
    else
      params.require(:booking).permit(:name, :notes, :start_time, :length, :room_id, :purpose, :repeat_mode, :repeat_until)
    end
  end

  def populate_from_camdram
    if user_is_imposter?
      # User is also an administrator so we don't need to care about their
      # peronal Camdram token as this will use the application token.
      @shows = impersonator.authorised_camdram_shows
      @societies = impersonator.authorised_camdram_societies
    else
      # User is genuine.
      @shows = current_user.authorised_camdram_shows
      @societies = current_user.authorised_camdram_societies
    end
  end

  def setup_booking_purpose
    unless @booking.purpose.nil?
      if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
        @booking.camdram_model = nil
      else
        id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
        return unless id.present?
        if Booking.purposes_with_shows.find_index(@booking.purpose.to_sym)
          @booking.camdram_model = CamdramShow.find(id)
        elsif Booking.purposes_with_societies.find_index(@booking.purpose.to_sym)
          @booking.camdram_model = CamdramSociety.find(id)
        else
          @booking.camdram_model = nil
        end
      end
    end
  end

  def authorise_booking_against_camdram
    # We can't authorise if there's no purpose given, but this get's caught by the model's validation.
    return true if @booking.purpose.nil?
    if Booking.admin_purposes.find_index(@booking.purpose.to_sym)
      # Admins can do anything.
      return current_user.admin?
    end
    if Booking.purposes_with_none.find_index(@booking.purpose.to_sym)
      # Nothing to authorise!
      return true
    end
    # We can't authorise if there's no show/society selected, but this get's caught by the model's validation.
    id = params[:booking]["camdram_id_#{@booking.purpose}".to_sym]
    return true if id.nil?
    if Booking.purposes_with_shows.find_index(@booking.purpose.to_sym)
      return current_user.authorised_camdram_shows.include? @booking.camdram_model
    elsif Booking.purposes_with_societies.find_index(@booking.purpose.to_sym)
      return current_user.authorised_camdram_societies.include? @booking.camdram_model
    else
      return false
    end
  end

  def notify_admins
    User.where(admin: true).each do |admin|
      ApprovalsMailer.notify(admin, @booking).deliver_later
    end unless @booking.approved
  end
end
