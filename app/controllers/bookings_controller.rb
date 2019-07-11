# frozen_string_literal: true

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
      @booking = Bookings::NewBookingService.perform(params, current_user, current_imposter, @camdram_entity_service)
    rescue Bookings::NotAuthorisedOnCamdramException => e
      @booking = e.booking
      alert = { 'class' => 'danger', 'message' => "You're not authorised to make this booking." }
      flash.now[:alert] = alert
      render :new and return
    end
    authorize! :create, @booking
    if @booking.save
      NotificationJob.perform_async(@booking.id, @booking.camdram_model.try(:to_global_id).try(:to_s))
      msg = "Added #{@booking.name}!"
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
      @booking = Bookings::UpdateBookingService.perform(params, current_user, current_imposter, @camdram_entity_service)
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

  def favourites
    json = params[:ids] || '[]'
    ids = JSON.parse(json).to_a.first(9)
    @bookings = Booking.where(id: ids)
      .eager_load(:user, :room)
      .accessible_by(current_ability, :read)
      .sort_by { |booking| ids.index(booking.id.to_s) }
    render 'favourites', layout: false
  end

  private

  def populate_camdram_entities
    @camdram_entity_service = CamdramEntitiesService.create(current_user, current_imposter)
    @shows = @camdram_entity_service.shows.reject { |s| s.camdram_object.nil? }
    @societies = @camdram_entity_service.societies.reject { |s| s.camdram_object.nil? }
  end
end
