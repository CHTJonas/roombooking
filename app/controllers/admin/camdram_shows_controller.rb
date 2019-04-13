# frozen_string_literal: true

module Admin
  class CamdramShowsController < DashboardController
    def index
      all_tuples = Admin::ShowRetrievalService.perform
      @show_tuples = Kaminari.paginate_array(all_tuples).page(params[:page])
    end

    def create
      id = create_camdram_show_params[:camdram_id]
      begin
        ActiveRecord::Base.transaction do
          @roombooking_show = CamdramShow.create_from_id(id)
          @roombooking_show.block_out_bookings(current_user)
          @camdram_show = @roombooking_show.camdram_object
        end
        respond_to do |format|
          format.js
        end
      rescue Exception => e
        Raven.capture_exception(e)
        format.js { head :internal_server_error }
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
      NewTermJob.perform_async
      head :no_content
    end

    def batch_import
      BatchImportJob.perform_async(current_user.id)
      head :no_content
    end

    def manual_import
      if Admin::ShowImportService.perform(params[:camdram_url], current_user)
        redirect_to action: :index
      else
        alert = { 'class' => 'danger', 'message' => 'An error occurred whilst performing the import.' }
        flash[:alert] = alert
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
