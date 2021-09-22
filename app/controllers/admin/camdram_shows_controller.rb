# frozen_string_literal: true

module Admin
  class CamdramShowsController < DashboardController
    def index
      all_tuples = Admin::ShowRetrievalService.perform
      @show_tuples = Kaminari.paginate_array(all_tuples).page(params[:page])

      @batch_import_result = BatchImportResult.where('queued > ?', Time.now - 2.hours).last
      if @batch_import_result
        Roombooking::CamdramApi.with do |client|
          @shows_imported_successfully = @batch_import_result.shows_imported_successfully.map { |sid| client.get_show(sid).name }
          @shows_imported_unsuccessfully = @batch_import_result.shows_imported_unsuccessfully.map { |sid| client.get_show(sid).name }
          @shows_already_imported = @batch_import_result.shows_already_imported.map { |sid| client.get_show(sid).name }
        end
      end
    end

    def create
      id = create_camdram_show_params[:camdram_id]
      respond_to do |format|
        ActiveRecord::Base.transaction do
          @roombooking_show = CamdramShow.create_from_id(id)
          @roombooking_show.block_out_bookings(current_user)
          @camdram_show = @roombooking_show.camdram_object
        end
        format.js
      rescue ActiveRecord::RecordInvalid => e
        format.js { render js: "rbModal('Import Error', 'Failed to import the specified show! #{e.message}');" }
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

    def batch_import
      BatchImportJob.perform_async(current_user.id, Time.now.to_f)
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
