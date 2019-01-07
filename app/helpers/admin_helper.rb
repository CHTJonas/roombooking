module AdminHelper
  def actions_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.nil?
      link_to 'Import', admin_import_show_path(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        link_to 'Deactivate', admin_deactivate_show_path(id.to_s), method: :post, class: 'btn btn-primary'
      else
        link_to 'Activate', admin_activate_show_path(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end

  def rehearsal_picker_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.present? && prod.active?
      number_field_tag(:max_rehearsals, prod.max_rehearsals, data: { url: admin_camdram_production_path(prod) })
    end
  end

  def audition_picker_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.present? && prod.active?
      number_field_tag(:max_auditions, prod.max_auditions, data: { url: admin_camdram_production_path(prod) })
    end
  end

  def meeting_picker_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.present? && prod.active?
      number_field_tag(:max_meetings, prod.max_meetings, data: { url: admin_camdram_production_path(prod) })
    end
  end

  def actions_for_society(show)
    id = show.id
    prod = CamdramSociety.find_by(camdram_id: id)
    if prod.nil?
      link_to 'Import', admin_import_society_path(id.to_s), method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        link_to 'Deactivate', admin_deactivate_society_path(id.to_s), method: :post, class: 'btn btn-primary'
      else
        link_to 'Activate', admin_activate_society_path(id.to_s), method: :post, class: 'btn btn-primary'
      end
    end
  end
end
