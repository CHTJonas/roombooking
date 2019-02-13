module CamdramHelper
  def progress_bar(value, quota)
    percentage = value.to_f / quota.to_f * 100
    content_tag :div, class: 'progress', style: 'margin-top: 3px;' do
      content_tag :div, value.to_s + '/' + quota.to_s, class: 'progress-bar', role: 'progressbar', style: 'width: ' + percentage.to_s + '%;'
    end
  end
end
