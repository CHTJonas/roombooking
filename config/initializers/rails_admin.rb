# https://github.com/sferik/rails_admin/wiki/Base-configuration

RailsAdmin.config do |config|

  config.main_app_name = ["Room Booking Back Office", ""]
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  config.show_gravatar = false

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
