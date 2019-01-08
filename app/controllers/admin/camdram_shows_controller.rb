module Admin
  class CamdramShowsController < DashboardController
    def index
      @camdram_shows = Array.new
      rooms = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom']
      rooms.each { |room| @camdram_shows += camdram.get_venue(room).shows }
    end

    def create
      id = params[:id].to_i
      unless id == 0
        roombooking_show = CamdramShow.create_from_id(id)
      end
      redirect_to action: :index
    end

    def update
      @camdram_show = CamdramShow.find(params[:id])
      @camdram_show.attributes = camdram_show_params
      if @camdram_show.valid?
        @camdram_show.save
      end
      if request.xhr?
        # Request is AJAX.
        head :no_content
      else
        redirect_to action: :index
      end
    end

    private

    def camdram_show_params
      params.require(:camdram_show).permit(:max_rehearsals, :max_auditions, :max_meetings, :active)
    end
  end
end
