module AdminHelper
  def actions_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', import_show_url(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', deactivate_show_url(id.to_s), method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', activate_show_url(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end

  def actions_for_society(show)
    id = show.id
    prod = CamdramSociety.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', import_society_url(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', deactivate_society_url(id.to_s), method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', activate_society_url(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end
end
