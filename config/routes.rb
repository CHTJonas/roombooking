Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'roombooking/admin_constraint'
  mount Sidekiq::Web => '/sidekiq', :constraints => Roombooking::AdminConstraint.new

  resources :venues
  resources :bookings
  resources :users

  get '/bookings/:id/approve' => 'bookings#approve', :as => :approve_booking
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', :as => :signin
  get '/logout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
