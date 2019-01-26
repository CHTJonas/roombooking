class CamdramShowsController < ApplicationController
  def show
    @camdram_show = CamdramShow.eager_load(:booking).find(params[:id])
    # TODO
    # authorize! :read, @camdram_show
    @external_show = @camdram_show.camdram_object
    @quota = @camdram_show.weekly_quota Time.now.beginning_of_week
  end
end
