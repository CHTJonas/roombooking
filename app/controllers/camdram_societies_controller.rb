class CamdramSocietiesController < ApplicationController
  def show
    @camdram_society = CamdramSociety.find(params[:id])
    # TODO
    # authorize! :read, @camdram_society
    @external_society = @camdram_society.camdram_object
    @quota = @camdram_society.weekly_quota Time.now.beginning_of_week
  end
end
