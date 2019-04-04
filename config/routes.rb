# frozen_string_literal: true

Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  # Admin Dashboard
  namespace :admin, constraints: must_be_admin do
    root to: 'dashboard#index', as: 'dashboard'
    get '/backup' => 'dashboard#backup'
    get '/info' => 'dashboard#info'
    resources :camdram_shows, only: [:index, :create, :update] do
      post 'new_term', on: :collection
      post 'batch_import', on: :collection
      post 'manual_import', on: :collection
    end
    resources :camdram_societies, only: [:index, :create, :update]
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
  resources :bookings do
    post 'favourites', on: :collection
  end
  resources :camdram_shows, only: [:show, :edit, :update]
  resources :camdram_societies, only: [:show, :edit, :update]
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
