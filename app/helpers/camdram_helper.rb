module CamdramHelper
  def progress_bar(value, quota)
    percentage = value.to_f / quota.to_f * 100
    content_tag :div, class: 'progress', style: 'margin-top: 3px;' do
      content_tag :div, value.to_s + '/' + quota.to_s, class: 'progress-bar', role: 'progressbar', style: 'width: ' + percentage.to_s + '%;'
    end
  end

  def camdram_url_for(camdram_entity)
    url = nil
    if camdram_entity.instance_of?(CamdramShow)
      url = Roombooking::CamdramAPI.url_for(camdram_entity.camdram_object)
    elsif camdram_entity.instance_of?(CamdramSociety)
      url = Roombooking::CamdramAPI.url_for(camdram_entity.camdram_object)
    else
      url = Roombooking::CamdramAPI.url_for(camdram_entity)
    end
    sanitize url
  end
end
