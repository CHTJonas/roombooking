module Admin
  class CamdramShowsController < DashboardController
    def index
      sorted_shows = Roombooking::CamdramAPI::ShowsEnumerator.retrieve
      @show_tuples = Array.new(sorted_shows.length)
      i = 0
      sorted_shows.each do |camdram_show|
        roombooking_show = CamdramShow.find_from_camdram(camdram_show)
        if roombooking_show.try(:dormant?)
          # Show are only marked dormant at the start/end of a term, in which
          # case they should be absent from the response from the Camdram API
          # (since they're no longer upcoming). Hence this operation won't be
          # called very often is so shouldn't be too computationally expensive.
          @show_tuples.delete_at(i)
        else
          @show_tuples[i] = [camdram_show, roombooking_show]
          i += 1
        end
      end
      @show_tuples = Kaminari.paginate_array(@show_tuples).page(params[:page])
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

    def new_term
      NewTermJob.perform_later
      head :no_content
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
