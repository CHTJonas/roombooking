class AdminController < ApplicationController
  before_action :must_be_admin!

  def view_camdram_shows
    @shows = Array.new
    venues = ['adc-theatre', 'adc-theatre-larkum-studio', 'adc-theatre-bar', 'corpus-playroom']
    venues.each { |venue| @shows += camdram.get_venue(venue).shows }
  end

  def import_camdram_show
    id = params[:id].to_i
    unless id == 0
      prod = CamdramProduction.create(camdram_id: id, max_bookings: 7, active: false)
      prod.save
    end
    redirect_to action: 'view_camdram_shows'
  end

  def activate_camdram_show
    id = params[:id].to_i
    unless id == 0
      prod = CamdramProduction.find_by(camdram_id: id)
      prod.active = true
      prod.save
    end
    redirect_to action: 'view_camdram_shows'
  end

  def deactivate_camdram_show
    id = params[:id].to_i
    unless id == 0
      prod = CamdramProduction.find_by(camdram_id: id)
      prod.active = false
      prod.save
    end
    redirect_to action: 'view_camdram_shows'
  end

  def view_camdram_societies
    @societies = camdram.get_orgs
  end

  def import_camdram_society
    id = params[:id].to_i
    unless id == 0
      soc = CamdramSociety.create(camdram_id: id, max_bookings: 7, active: false)
      soc.save
    end
    redirect_to action: 'view_camdram_societies'
  end

  def activate_camdram_society
    id = params[:id].to_i
    unless id == 0
      soc = CamdramSociety.find_by(camdram_id: id)
      soc.active = true
      soc.save
    end
    redirect_to action: 'view_camdram_societies'
  end

  def deactivate_camdram_society
    id = params[:id].to_i
    unless id == 0
      soc = CamdramSociety.find_by(camdram_id: id)
      soc.active = false
      soc.save
    end
    redirect_to action: 'view_camdram_societies'
  end

  private

  def must_be_admin!
    unless user_is_admin?
      # This method should never be needed as routes are constrained by
      # Roombooking::AdminConstraint however it's included just to be safe.
      alert = { 'class' => 'danger', 'message' => "Acess denied — you don't appear to be an administrator!" }
      flash.now[:alert] = alert
      render 'layouts/blank', locals: {reason: 'user not admin'}, status: :forbidden and return
    end
  end
end
