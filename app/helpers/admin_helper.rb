module AdminHelper
  def actions_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', admin_import_show_path(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', admin_deactivate_show_path(id.to_s), method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', admin_activate_show_path(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end

  def actions_for_society(show)
    id = show.id
    prod = CamdramSociety.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', admin_import_society_path(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', admin_deactivate_society_path(id.to_s), method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', admin_activate_society_path(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end
end
