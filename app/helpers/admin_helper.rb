# frozen_string_literal: true

module AdminHelper
  def configure_entity_tag(camdram_entity, roombooking_entity)
    if roombooking_entity.present?
      content_tag :td do
        link_to roombooking_entity.name, url_for(roombooking_entity)
      end
    else
      content_tag(:td, camdram_entity.name)
    end
  end

  def actions_for_show(camdram_show, roombooking_show)
    if roombooking_show.nil?
      roombooking_show = CamdramShow.new
      form_with model: roombooking_show, url: admin_camdram_shows_path do |form|
        field1 = form.hidden_field :camdram_id, value: camdram_show.id
        field2 = form.submit 'Import', class: 'btn btn-primary'
        field1 + field2
      end
    else
      if roombooking_show.active?
        form_with model: roombooking_show, url: admin_camdram_show_path(roombooking_show) do |form|
          field1 = form.hidden_field :active, value: !roombooking_show.active?
          field2 = form.submit 'Deactivate', class: 'btn btn-primary'
          field1 + field2
        end
      else
        form_with model: roombooking_show, url: admin_camdram_show_path(roombooking_show) do |form|
          field1 = form.hidden_field :active, value: !roombooking_show.active?
          field2 = form.submit 'Activate', class: 'btn btn-primary'
          field1 + field2
        end
      end
    end
  end

  def actions_for_society(camdram_society, roombooking_society)
    if roombooking_society.nil?
      roombooking_society = CamdramSociety.new
      form_with model: roombooking_society, url: admin_camdram_societies_path do |form|
        field1 = form.hidden_field :camdram_id, value: camdram_society.id
        field2 = form.submit 'Import', class: 'btn btn-primary'
        field1 + field2
      end
    else
      if roombooking_society.active?
        form_with model: roombooking_society, url: admin_camdram_society_path(roombooking_society) do |form|
          field1 = form.hidden_field :active, value: !roombooking_society.active?
          field2 = form.submit 'Deactivate', class: 'btn btn-primary'
          field1 + field2
        end
      else
        form_with model: roombooking_society, url: admin_camdram_society_path(roombooking_society) do |form|
          field1 = form.hidden_field :active, value: !roombooking_society.active?
          field2 = form.submit 'Activate', class: 'btn btn-primary'
          field1 + field2
        end
      end
    end
  end

  def time_diff_for_batch_import_job(batch_import_result)
    ChronicDuration.output(Time.now - batch_import_result.queued, units: 2)
  end
end
