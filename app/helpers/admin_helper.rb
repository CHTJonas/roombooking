module AdminHelper
  def actions_for_show(show)
    id = show.id
    prod = CamdramProduction.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', '/admin/shows/' + id.to_s + '/import', method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', '/admin/shows/' + id.to_s + '/deactivate', method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', '/admin/shows/' + id.to_s + '/activate', method: :post, class: 'btn btn-primary'
      end
    end
  end

  def actions_for_society(show)
    id = show.id
    prod = CamdramSociety.find_by(camdram_id: id)
    if prod.nil?
      return link_to 'Import', '/admin/societies/' + id.to_s + '/import', method: :post, class: 'btn btn-primary'
    else
      if prod.active?
        return link_to 'Deactivate', '/admin/societies/' + id.to_s + '/deactivate', method: :post, class: 'btn btn-primary'
      else
        return link_to 'Activate', '/admin/societies/' + id.to_s + '/activate', method: :post, class: 'btn btn-primary'
      end
    end
  end
end
