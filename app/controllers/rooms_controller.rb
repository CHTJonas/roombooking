class RoomsController < ApplicationController
  helper_method :events_for

  def index
    @rooms = Room
      .then { |_| request.format == :ics ? _.eager_load(booking: :user)
        .where('bookings.approved = ?', true)
        : _ }
      .accessible_by(current_ability, :read)
    respond_to do |format|
      format.html
      format.ics
    end
  end

  def new
    authorize! :create, Room
    @room = Room.new
  end

  def edit
    @room = Room.find(params[:id])
    authorize! :edit, @room
  end

  def create
    @room = Room.new(room_params)
    authorize! :create, @room
    if @room.save
      alert = { 'class' => 'success', 'message' => "Added #{@room.name}!" }
      flash[:alert] = alert
      redirect_to @room
    else
      alert = { 'class' => 'danger', 'message' => @room.errors.full_messages.first }
      flash.now[:alert] = alert
      render :new
    end
  end

  def update
    @room = Room.find(params[:id])
    authorize! :edit, @room
    if @room.update(room_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@room.name}!"}
      flash[:alert] = alert
      redirect_to @room
    else
      alert = { 'class' => 'danger', 'message' => @room.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  def show
    @room = Room.eager_load(approved_bookings: :user).find(params[:id])
    authorize! :read, @room
    start_date = (params[:start_date] ? Date.parse(params[:start_date]) : Date.today).beginning_of_week
    end_date = start_date + 7.days
    @events = @room.events_in_range(start_date, end_date)
    respond_to do |format|
      format.html
      format.ics
    end
  end

  def destroy
    @room = Room.find(params[:id])
    authorize! :destroy, @room
    @room.destroy
    alert = { 'class' => 'success', 'message' => "Deleted #{@room.name}!"}
    flash[:alert] = alert
    redirect_to rooms_path
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end
