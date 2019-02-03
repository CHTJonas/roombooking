module Admin
  class CamdramShowsController < DashboardController
    def index
      sorted_shows = enumerate_camdram_shows
      @camdram_shows = Kaminari.paginate_array(sorted_shows).page(params[:page])
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

    def batch_import
      shows = enumerate_camdram_shows
      shows.each do |camdram_show|
        roombooking_show = CamdramShow.create_from_camdram(camdram_show)
        roombooking_show.update(active: true)
      end
      redirect_to action: :index
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

    def enumerate_camdram_shows
      list_of_shows = LinkedList::List.new
      rooms = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom']
      rooms.each do |room|
        shows = Roombooking::CamdramAPI.with { |client| client.get_venue(room).shows }
        shows.each { |s| list_of_shows << s }
      end
      list_of_shows.to_a.sort_by(&:name)
    end

    def camdram_show_params
      params.require(:camdram_show).permit(:max_rehearsals, :max_auditions, :max_meetings, :active)
    end
  end
end
