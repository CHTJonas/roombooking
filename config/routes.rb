Rails.application.routes.draw do
  resources :users
  root :to => 'high_voltage/pages#show', id: 'index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new', :as => :signin
  get '/logout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
