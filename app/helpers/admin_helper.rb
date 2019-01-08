module AdminHelper
  def actions_for_show(camdram_show, roombooking_show)
    if roombooking_show.nil?
      form_tag admin_camdram_shows_path, method: :post do
        field1 = hidden_field_tag :id, camdram_show.id
        field2 = submit_tag 'Import', class: 'btn btn-primary'
        field1 + field2
      end
    else
      if roombooking_show.active?
        form_with(model: roombooking_show, url: admin_camdram_show_path(roombooking_show), local: true) do |form|
          field1 = form.hidden_field :active, value: !roombooking_show.active?
          field2 = form.submit 'Deactivate', class: 'btn btn-primary'
          field1 + field2
        end
      else
        form_with(model: roombooking_show, url: admin_camdram_show_path(roombooking_show), local: true) do |form|
          field1 = form.hidden_field :active, value: !roombooking_show.active?
          field2 = form.submit 'Activate', class: 'btn btn-primary'
          field1 + field2
        end
      end
    end
  end

  def actions_for_society(camdram_society, roombooking_society)
    if roombooking_society.nil?
      form_tag admin_camdram_societies_path, method: :post do
        field1 = hidden_field_tag :id, camdram_society.id
        field2 = submit_tag 'Import', class: 'btn btn-primary'
        field1 + field2
      end
    else
      if roombooking_society.active?
        form_with(model: roombooking_society, url: admin_camdram_society_path(roombooking_society), local: true) do |form|
          field1 = form.hidden_field :active, value: !roombooking_society.active?
          field2 = form.submit 'Deactivate', class: 'btn btn-primary'
          field1 + field2
        end
      else
        form_with(model: roombooking_society, url: admin_camdram_society_path(roombooking_society), local: true) do |form|
          field1 = form.hidden_field :active, value: !roombooking_society.active?
          field2 = form.submit 'Activate', class: 'btn btn-primary'
          field1 + field2
        end
      end
    end
  end
end
