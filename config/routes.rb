# frozen_string_literal: true

Rails.application.routes.draw do
  must_be_admin = Roombooking::RouteConstraints::AdminConstraint.new

  # Backend Admin Interfaces
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  require 'sidekiq/throttled/web'
  Sidekiq::Throttled::Web.enhance_queues_tab!
  mount Sidekiq::Web => '/admin/sidekiq', as: 'sidekiq', constraints: must_be_admin
  mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin', constraints: must_be_admin

  # Admin Dashboard
  namespace :admin do
    root to: 'dashboard#index', as: 'dashboard'
    get 'site_info' => 'dashboard#site_info'
    get 'gem_info' => 'dashboard#gem_info'
    get 'backup' => 'dashboard#backup'
    resources :camdram_shows, only: [:index, :create, :update] do
      post 'new_term', on: :collection
      post 'batch_import', on: :collection
      post 'manual_import', on: :collection
    end
    resources :camdram_societies, only: [:index, :create, :update]
  end

  # Searching
  namespace :search do
    get '/bookings' => 'bookings#search', as: 'bookings'
    get '/users' => 'users#search', as: 'users'
  end

  # RESTful Entities
  resources :bookings do
    post 'favourites', on: :collection
  end
  resources :camdram_shows, only: [:show, :edit, :update]
  resources :camdram_societies, only: [:show, :edit, :update]
  resources :rooms
  resources :users do
    get '2fa', to: 'two_factor_setup#show', as: 'show_2fa_qr', on: :member
    post '2fa', to: 'two_factor_setup#validate', as: 'validate_2fa_code', on: :member
    get 'validate', on: :member
    post 'impersonate', on: :member
    post 'discontinue_impersonation', on: :collection,
      as: 'discontinue_impersonation_of'
  end

  # Contact form
  get '/contact' => 'contact_form#new'
  post '/contact' => 'contact_form#create'

  # Authentication
  get '/login' => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  delete '/logout' => 'sessions#destroy'
  delete '/logout_everywhere' => 'sessions#destroy_all'
  get '/auth/2fa' => 'two_factor#new'
  post '/auth/2fa' => 'two_factor#create'
  get '/auth/:provider/callback' => 'sessions#create', as: :auth_callback
  get '/auth/failure' => 'sessions#failure', as: :auth_failure

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
