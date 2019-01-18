Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  # Admin Dashboard
  get '/admin', to: redirect('/admin/dashboard'), constraints: must_be_admin
  namespace :admin do
    resources :dashboard, only: [:index], constraints: must_be_admin
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
  resources :rooms
  resources :users

  # Authentication
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'

  # Health & Performance
  mount Peek::Railtie => '/peek'
  health_check_routes
end
