module AdminHelper
  def actions_for_show(show, prod)
    if prod.nil?
      link_to 'Import', admin_import_show_path(show.id), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        link_to 'Deactivate', admin_deactivate_show_path(show.id), method: :post, class: 'btn btn-primary'
      else
        link_to 'Activate', admin_activate_show_path(show.id), method: :post, class: 'btn btn-primary'
      end
    end
  end

  def actions_for_society(camdram_society, roombooking_society)
    if roombooking_society.nil?
      link_to 'Import', admin_import_society_path(camdram_society.id), method: :post, class: 'btn btn-primary'
    else
      if roombooking_society.active?
        link_to 'Deactivate', admin_deactivate_society_path(camdram_society.id), method: :post, class: 'btn btn-primary'
      else
        link_to 'Activate', admin_activate_society_path(camdram_society.id), method: :post, class: 'btn btn-primary'
      end
    end
  end
end
