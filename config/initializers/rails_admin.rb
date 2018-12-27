# https://github.com/sferik/rails_admin/wiki/Base-configuration

RailsAdmin.config do |config|

  config.main_app_name = ["Room Booking Back Office", ""]
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version'
  config.show_gravatar = false

  excluded_models = ['CamdramToken', 'LogEvent']
  audited_models = ['Booking', 'User', 'Venue']

  config.model 'User' do
    exclude_fields :log_events, :camdram_token
  end

  config.actions do
    dashboard do
      except excluded_models
    end
    index do
      except excluded_models
    end
    new do
      except excluded_models
    end
    export do
      except excluded_models
    end
    bulk_delete do
      except excluded_models
    end
    show do
      except excluded_models
    end
    edit do
      except excluded_models
    end
    delete do
      except excluded_models
    end
    show_in_app do
      except excluded_models
    end
    history_index do
      only audited_models
      except excluded_models
    end
    history_show do
      only audited_models
      except excluded_models
    end
  end
end
