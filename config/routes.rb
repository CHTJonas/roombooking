# frozen_string_literal: true

Rails.application.routes.draw do

  # Admin Dashboard
  authenticate :user, lambda { |u| u.admin? } do
    namespace :admin do
      root to: 'dashboard#index', as: 'dashboard'
      get 'backup' => 'dashboard#backup'
      get 'info' => 'dashboard#info'
      resources :camdram_shows, only: [:index, :create, :update] do
        post 'new_term', on: :collection
        post 'batch_import', on: :collection
        post 'manual_import', on: :collection
      end
      resources :camdram_societies, only: [:index, :create, :update]
    end
  end

  # Backend Admin Interfaces
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  require 'sidekiq/throttled/web'
  Sidekiq::Throttled::Web.enhance_queues_tab!
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq', as: 'sidekiq'
    mount RailsAdmin::Engine => '/admin/back-office', as: 'rails_admin'
  end

  # Searching
  namespace :search do
    get 'bookings' => 'bookings#search', as: 'bookings'
    get 'users' => 'users#search', as: 'users'
  end

  # RESTful Entities
  resources :bookings do
    post 'favourites', on: :collection
  end
  resources :camdram_shows, only: [:show, :edit, :update]
  resources :camdram_societies, only: [:show, :edit, :update]
  resources :rooms
  resources :users do
    post 'impersonate', on: :member
    post 'discontinue_impersonation', on: :collection,
      as: 'discontinue_impersonation_of'
  end

  # Authentication
  devise_for :users, controllers: {
    sessions: 'sessions',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  devise_scope :user do
    match 'login'  => 'sessions#new', as: :new_user_session, via: :get
    match 'logout' => 'sessions#destroy', as: :destroy_user_session, via: [:get, :delete]
  end

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
