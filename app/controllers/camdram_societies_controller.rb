# frozen_string_literal: true

class CamdramSocietiesController < ApplicationController
  def show
    @camdram_society = CamdramSociety.find(params[:id])
    authorize! :read, @camdram_society
    @external_society = @camdram_society.camdram_object
    if @external_society.nil?
      alert = { 'class' => 'warning', 'message' => 'This society appears to have been deleted from Camdram.' }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'camdram object does not exist'}, status: :not_found, formats: :html and return
    end
    @quota = @camdram_society.weekly_quota Time.zone.today.beginning_of_week
    @bookings = @camdram_society.bookings.where(purpose: :meeting_of)
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
