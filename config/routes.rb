Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  # Admin Dashboard
  namespace :admin do
    root to: redirect('/admin/dashboard'), constraints: must_be_admin
    get '/dashboard' => 'dashboard#index', constraints: must_be_admin
    get '/backup' => 'dashboard#backup', constraints: must_be_admin
    resources :camdram_shows, only: [:index, :create, :update], constraints: must_be_admin
    resources :camdram_societies, only: [:index, :create, :update], constraints: must_be_admin
  end

  # Backend Admin Interfaces
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/admin/sidekiq', as: 'sidekiq', constraints: must_be_admin
  mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin', constraints: must_be_admin

  # Searching
  namespace :search do
    get '/bookings' => 'bookings#search', as: 'bookings'
    get '/users' => 'users#search', as: 'users', constraints: must_be_admin
  end

  # RESTful Entities
  resources :bookings
  resources :camdram_shows, only: [:show]
  resources :camdram_societies, only: [:show]
  resources :rooms
  resources :users do
    post 'impersonate', on: :member, constraints: must_be_admin
    post 'discontinue_impersonation', on: :collection,
      as: 'discontinue_impersonation_of'
  end

  # Authentication
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  # Health & Performance
  mount Peek::Railtie => '/peek'
  health_check_routes
end

# Fallback to catch unroutable URLs. This needs to be inserted into the
# Rails router after the HighVoltage static pages dependency injection.
# See: https://github.com/thoughtbot/high_voltage/issues/275
Rails.application.config.after_initialize do |application|
  application.routes.append do
    match '*unmatched_route', to: 'application#route_not_found', via: :all
  end
end
