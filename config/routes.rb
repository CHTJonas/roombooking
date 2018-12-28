Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  get '/admin' => 'admin#index', constraints: must_be_admin
  get '/admin/shows' => 'admin#view_camdram_shows', constraints: must_be_admin
  post '/admin/shows/:id/import' => 'admin#import_camdram_show', constraints: must_be_admin
  post '/admin/shows/:id/activate' => 'admin#activate_camdram_show', constraints: must_be_admin
  post '/admin/shows/:id/deactivate' => 'admin#deactivate_camdram_show', constraints: must_be_admin
  get '/admin/societies' => 'admin#view_camdram_societies', constraints: must_be_admin
  post '/admin/societies/:id/import' => 'admin#import_camdram_society', constraints: must_be_admin
  post '/admin/societies/:id/activate' => 'admin#activate_camdram_society', constraints: must_be_admin
  post '/admin/societies/:id/deactivate' => 'admin#deactivate_camdram_society', constraints: must_be_admin

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/admin/sidekiq', constraints: must_be_admin
  mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin', constraints: must_be_admin

  resources :venues
  resources :bookings
  resources :users

  post '/bookings/:id/approve' => 'bookings#approve', as: :approve_booking
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', as: :signin
  get '/logout' => 'sessions#destroy', as: :signout
  get '/auth/failure' => 'sessions#failure'
end
