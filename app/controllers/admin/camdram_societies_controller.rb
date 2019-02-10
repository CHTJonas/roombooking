module Admin
  class CamdramSocietiesController < DashboardController
    def index
      sorted_societies = Roombooking::CamdramAPI.with { |client| client.get_societies.sort_by(&:name) }
      @society_tuples = Array.new(sorted_societies.length)
      sorted_societies.each_with_index do |camdram_society, i|
        roombooking_society = CamdramSociety.find_from_camdram(camdram_society)
        @society_tuples[i] = [camdram_society, roombooking_society]
      end
      @society_tuples = Kaminari.paginate_array(@society_tuples).page(params[:page])
    end

    def create
      @roombooking_society = CamdramSociety.new(create_camdram_society_params)
      @camdram_society = @roombooking_society.camdram_object
      respond_to do |format|
        if @roombooking_society.save
          format.js
        end
      end
    end

    def update
      @roombooking_society = CamdramSociety.find(params[:id])
      @camdram_society = @roombooking_society.camdram_object
      respond_to do |format|
        if @roombooking_society.update(update_camdram_society_params)
          if update_camdram_society_params.include? :active
            format.js
          else
            format.js { head :no_content }
          end
        end
      end
    end

    private

    def create_camdram_society_params
      params.require(:camdram_society).permit(:camdram_id)
    end

    def update_camdram_society_params
      params.require(:camdram_society).permit(:max_meetings, :active)
    end
  end
end
