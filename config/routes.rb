Rails.application.routes.draw do
  require 'roombooking/route_constraints'
  must_be_admin = Roombooking::AdminConstraint.new

  namespace :admin do
    get '/' => 'dashboard#view', as: 'view_dashboard', constraints: must_be_admin
    get '/shows' => 'shows#view', as: 'view_shows', constraints: must_be_admin
    post '/shows/:id/import' => 'shows#import', as: 'import_show', constraints: must_be_admin
    post '/shows/:id/activate' => 'shows#activate', as: 'activate_show', constraints: must_be_admin
    post '/shows/:id/deactivate' => 'shows#deactivate', as: 'deactivate_show', constraints: must_be_admin
    get '/societies' => 'societies#view', as: 'view_societies', constraints: must_be_admin
    post '/societies/:id/import' => 'societies#import', as: 'import_society', constraints: must_be_admin
    post '/societies/:id/activate' => 'societies#activate', as: 'activate_society', constraints: must_be_admin
    post '/societies/:id/deactivate' => 'societies#deactivate', as: 'deactivate_society', constraints: must_be_admin
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
