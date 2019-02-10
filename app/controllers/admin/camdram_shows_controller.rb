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
      @roombooking_show = CamdramShow.new(create_camdram_show_params)
      @camdram_show = @roombooking_show.camdram_object
      respond_to do |format|
        if @roombooking_show.save
          format.js
        end
      end
    end

    def update
      @roombooking_show = CamdramShow.find(params[:id])
      @camdram_show = @roombooking_show.camdram_object
      respond_to do |format|
        if @roombooking_show.update(update_camdram_show_params)
          if update_camdram_show_params.include? :active
            format.js
          else
            format.js { head :no_content }
          end
        end
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

    def create_camdram_show_params
      params.require(:camdram_show).permit(:camdram_id)
    end

    def update_camdram_show_params
      params.require(:camdram_show).permit(:max_rehearsals, :max_auditions, :max_meetings, :active)
    end
  end
end
