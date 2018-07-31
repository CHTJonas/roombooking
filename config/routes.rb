Rails.application.routes.draw do
  resources :venues

  resources :users
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', :as => :signin
  get '/logout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
