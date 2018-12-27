Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  get '/admin' => 'admin#index', constraints: must_be_admin

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
