Rails.application.routes.draw do
  resources :assignments
  resources :users
  resources :study_groups, only: [ :index, :show, :create ] do
    post :join, on: :member
    resources :study_group_messages, only: :create
  end

  get  '/login',   to: 'sessions#new',     as: 'login'
  post '/login',   to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  get '/dashboard', to: 'assignments#index', as: 'dashboard'

  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"
end