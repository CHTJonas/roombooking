module Admin
  class CamdramProductionsController < DashboardController
    def update
      @camdram_production = CamdramProduction.find(params[:id])
      @camdram_production.attributes = camdram_production_params
      if @camdram_production.valid?
        @camdram_production.save
      end
      head :no_content
    end

    private

    def camdram_production_params
      params.require(:camdram_production).permit(:max_rehearsals, :max_auditions, :max_meetings)
    end
  end
end
