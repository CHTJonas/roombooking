module Admin
  class CamdramSocietiesController < DashboardController
    def update
      @camdram_society = CamdramSociety.find(params[:id])
      @camdram_society.attributes = camdram_society_params
      if @camdram_society.valid?
        @camdram_society.save
      end
      head :no_content
    end

    private

    def camdram_society_params
      params.require(:camdram_society).permit(:max_meetings)
    end
  end
end
