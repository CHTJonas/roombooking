Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  get '/admin' => 'admin#index', as: 'admin', constraints: must_be_admin
  get '/admin/shows' => 'admin#view_camdram_shows', as: 'admin_shows', constraints: must_be_admin
  post '/admin/shows/:id/import' => 'admin#import_camdram_show', as: 'import_show', constraints: must_be_admin
  post '/admin/shows/:id/activate' => 'admin#activate_camdram_show', as: 'activate_show', constraints: must_be_admin
  post '/admin/shows/:id/deactivate' => 'admin#deactivate_camdram_show', as: 'deactivate_show', constraints: must_be_admin
  get '/admin/societies' => 'admin#view_camdram_societies', as: 'admin_societies', constraints: must_be_admin
  post '/admin/societies/:id/import' => 'admin#import_camdram_society', as: 'import_society', constraints: must_be_admin
  post '/admin/societies/:id/activate' => 'admin#activate_camdram_society', as: 'activate_society', constraints: must_be_admin
  post '/admin/societies/:id/deactivate' => 'admin#deactivate_camdram_society', as: 'deactivate_society', constraints: must_be_admin

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/admin/sidekiq', as: 'sidekiq', constraints: must_be_admin
  mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin', constraints: must_be_admin

  resources :venues
  resources :bookings
  resources :users

  post '/bookings/:id/approve' => 'bookings#approve', as: :approve_booking
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'
end
