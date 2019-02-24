class BookingsController < ApplicationController
  before_action :populate_camdram_entities,
    only: [:new, :edit, :create, :update]

  def index
    @bookings = Booking.order(created_at: :desc)
      .eager_load(:user, :room)
      .accessible_by(current_ability, :read)
      .page(params[:page]).without_count
  end

  def new
    authorize! :create, Booking
    @booking = Booking.new
  end

  def edit
    @booking = Booking.find(params[:id])
    authorize! :edit, @booking
  end

  def create
    begin
      service = Bookings::NewBookingService.perform(params, current_user, impersonator, @camdram_entity_service)
      @booking = service.booking
    rescue Bookings::NotAuthorisedOnCamdramException => e
      @booking = e.booking
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
      flash.now[:alert] = alert
      render :new and return
    end
    authorize! :create, @booking
    if @booking.save
      NotificationJob.perform_later(@booking.id)
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
    begin
      service = Bookings::UpdateBookingService.perform(params, current_user, impersonator, @camdram_entity_service)
      @booking = service.booking
    rescue Bookings::NotAuthorisedOnCamdramException => e
      @booking = e.booking
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
      flash.now[:alert] = alert
      render :edit and return
    end
    authorize! :edit, @booking
    if @booking.save
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

  def populate_camdram_entities
    @camdram_entity_service = CamdramEntitiesService.perform(current_user, impersonator)
    @shows = @camdram_entity_service.shows
    @societies = @camdram_entity_service.societies
  end
end
