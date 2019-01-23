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
    @room = Room.find(params[:id])
    authorize! :read, @room
    respond_to do |format|
      format.html
      format.ics { @bookings = @room.booking.eager_load(:user).where(approved: true) }
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

  protected

  def events_for(room)
    start_date = (params[:start_date] ? Date.parse(params[:start_date]) : Date.today).beginning_of_week
    end_date = start_date + 7.days

    daily_bookings = room.booking.where(repeat_mode: :none)
                                  .where(start_time: start_date..end_date)
                                  .accessible_by(current_ability, :read)
    daily_events = Array.new(daily_bookings.length)
    daily_bookings.to_a.each_with_index { |val, index| daily_events[index] = Event.create_from_booking(val) }

    repeat_events = LinkedList::List.new

    daily_repeat_bookings = room.booking.where(repeat_mode: :daily)
                                         .where(start_time: Time.at(0)..end_date)
                                         .where(repeat_until: start_date..DateTime::Infinity.new)
                                         .accessible_by(current_ability, :read)
    daily_repeat_bookings.to_a.each do |booking|
      (booking.start_time.to_date..booking.repeat_until).each do |date|
        break if date > end_date
        offset = date - booking.start_time.to_date
        repeat_events.push Event.create_from_booking(booking, offset)
      end
    end

    weekly_repeat_bookings = room.booking.where(repeat_mode: :weekly)
                                          .where(start_time: Time.at(0)..end_date)
                                          .where(repeat_until: start_date..DateTime::Infinity.new)
                                          .accessible_by(current_ability, :read)
    weekly_repeat_bookings.to_a.each do |booking|
      offset = start_date - booking.start_time.to_date.beginning_of_week
      repeat_events.push Event.create_from_booking(booking, offset)
    end

    daily_events + repeat_events.to_a
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end
