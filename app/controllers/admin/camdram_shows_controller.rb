module Admin
  class CamdramShowsController < DashboardController
    def index
      sorted_shows = Roombooking::CamdramAPI::ShowsEnumerator.retrieve
      @camdram_shows = Kaminari.paginate_array(sorted_shows).page(params[:page])
    end

    def create
      id = params[:id].to_i
      CamdramShow.create_from_id(id) unless id == 0
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

    def batch_import
      BatchImportJob.perform_later
      head :no_content
    end

    def manual_import
      uri = URI(params[:camdram_url])
      path = uri.path.split('/')
      if path.length == 3 && path[1] == 'shows'
        slug = path[2]
        camdram_show = Roombooking::CamdramAPI.with { |client| client.get_show(slug) }
        roombooking_show = CamdramShow.create_from_camdram(camdram_show)
        roombooking_show.update(active: true)
      end
      redirect_to action: :index
    end

    private

    def camdram_show_params
      params.require(:camdram_show).permit(:max_rehearsals, :max_auditions, :max_meetings, :active)
    end
  end
end
