class CamdramSocietiesController < ApplicationController
  def show
    @camdram_society = CamdramSociety.eager_load(:approved_bookings).find(params[:id])
    authorize! :read, @camdram_society
    @external_society = @camdram_society.camdram_object
    @quota = @camdram_society.weekly_quota Date.today.beginning_of_week
  end
end
