# frozen_string_literal: true

class CamdramShowsController < ApplicationController
  def show
    @camdram_show = CamdramShow.find(params[:id])
    authorize! :read, @camdram_show
    @external_show = @camdram_show.camdram_object
    if @external_show.nil?
      alert = { 'class' => 'warning', 'message' => 'This show appears to have been deleted from Camdram.' }
      flash[:alert] = alert
    end
    @quota = @camdram_show.weekly_quota Time.zone.today.beginning_of_week
    @bookings = @camdram_show.bookings.where(purpose: %i[audition_for meeting_for rehearsal_for])
  end

  def edit
    @camdram_show = CamdramShow.find(params[:id])
    authorize! :edit, @camdram_show
  end

  def update
    @camdram_show = CamdramShow.find(params[:id])
    authorize! :edit, @camdram_show
    if @camdram_show.update(camdram_show_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@camdram_show.name}!" }
      flash[:alert] = alert
      redirect_to @camdram_show
    else
      alert = { 'class' => 'danger', 'message' => @camdram_show.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  private

  def camdram_show_params
    params.require(:camdram_show).permit(:slack_webhook)
  end
end
