# frozen_string_literal: true

module Admin
  class CamdramShowsController < DashboardController
    def index
      all_tuples = Admin::ShowRetrievalService.perform
      @show_tuples = Kaminari.paginate_array(all_tuples).page(params[:page])
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
      BatchImportJob.perform_later(current_user.id)
      head :no_content
    end

    def manual_import
      if Admin::ShowImportService.perform(params[:camdram_url])
        redirect_to action: :index
      else
        # TODO display an error message to the user.
        redirect_to action: :index
      end
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
