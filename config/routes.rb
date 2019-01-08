Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  namespace :admin do
    resources :dashboard, only: [:index], constraints: must_be_admin
    resources :camdram_shows, only: [:index, :create, :update], constraints: must_be_admin
    resources :camdram_societies, only: [:index, :create, :update], constraints: must_be_admin
  end

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/admin/sidekiq', as: 'sidekiq', constraints: must_be_admin
  mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin', constraints: must_be_admin

  namespace :search do
    get '/bookings' => 'bookings#search', as: 'bookings'
    get '/users' => 'bookings#search', as: 'users', constraints: must_be_admin
  end

  resources :venues
  resources :bookings
  resources :users

  post '/bookings/:id/approve' => 'bookings#approve', as: :approve_booking
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', as: :login
  get '/logout' => 'sessions#destroy', as: :logout
  get '/auth/failure' => 'sessions#failure'
end
