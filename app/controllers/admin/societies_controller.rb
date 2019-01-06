module Admin
  class SocietiesController < DashboardController
    def view
      @societies = camdram.get_societies
    end

    def import
      id = params[:id].to_i
      unless id == 0
        soc = CamdramSociety.create(camdram_id: id, max_bookings: 7, active: false)
        soc.save
      end
      redirect_to action: 'view'
    end

    def activate
      id = params[:id].to_i
      unless id == 0
        soc = CamdramSociety.find_by(camdram_id: id)
        soc.active = true
        soc.save
      end
      redirect_to action: 'view'
    end

    def deactivate
      id = params[:id].to_i
      unless id == 0
        soc = CamdramSociety.find_by(camdram_id: id)
        soc.active = false
        soc.save
      end
      redirect_to action: 'view'
    end
  end
end
