module Admin
  class CamdramProductionsController < DashboardController
    def update
      @camdram_production = CamdramProduction.find(params[:id])
      @camdram_production.update(camdram_production_params)
    end

    private

    def camdram_production_params
      params.require(:camdram_production).permit(:max_rehearsals, :max_auditions, :max_meetings)
    end
  end
end
