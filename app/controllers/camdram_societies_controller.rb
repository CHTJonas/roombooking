# frozen_string_literal: true

class CamdramSocietiesController < ApplicationController
  def show
    @camdram_society = CamdramSociety.eager_load(:approved_bookings).find(params[:id])
    authorize! :read, @camdram_society
    @external_society = @camdram_society.camdram_object
    @quota = @camdram_society.weekly_quota Date.today.beginning_of_week
  end

  def edit
    @camdram_society = CamdramSociety.find(params[:id])
    authorize! :edit, @camdram_society
  end

  def update
    @camdram_society = CamdramSociety.find(params[:id])
    authorize! :edit, @camdram_society
    if @camdram_society.update(camdram_society_params)
      alert = { 'class' => 'success', 'message' => "Updated #{@camdram_society.name}!"}
      flash[:alert] = alert
      redirect_to @camdram_society
    else
      alert = { 'class' => 'danger', 'message' => @camdram_society.errors.full_messages.first }
      flash.now[:alert] = alert
      render :edit
    end
  end

  private

  def camdram_society_params
    params.require(:camdram_society).permit(:slack_webhook)
  end
end
