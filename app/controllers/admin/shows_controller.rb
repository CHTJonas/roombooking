module Admin
  class ShowsController < DashboardController
    def view
      @shows = Array.new
      venues = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom']
      venues.each { |venue| @shows += camdram.get_venue(venue).shows }
    end

    def import
      id = params[:id].to_i
      unless id == 0
        prod = CamdramProduction.create(camdram_id: id,
                                        max_rehearsals: 12,
                                        max_auditions: 10,
                                        max_meetings: 4,
                                        active: false)
        prod.save
      end
      redirect_to action: 'view'
    end

    def activate
      id = params[:id].to_i
      unless id == 0
        prod = CamdramProduction.find_by(camdram_id: id)
        prod.active = true
        prod.save
      end
      redirect_to action: 'view'
    end

    def deactivate
      id = params[:id].to_i
      unless id == 0
        prod = CamdramProduction.find_by(camdram_id: id)
        prod.active = false
        prod.save
      end
      redirect_to action: 'view'
    end
  end
end
