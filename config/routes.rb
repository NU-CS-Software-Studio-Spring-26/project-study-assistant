Rails.application.routes.draw do
  resources :assignments do
    member do
      patch :toggle_done
    end
  end
  resources :users, except: [ :index ] do
    post :sync_ical, on: :member
  end
  resources :study_groups do
    post :join, on: :member
    delete :leave, on: :member
    delete :kick, on: :member
    resources :study_group_messages, only: :create
  end

  get  "/login",   to: "sessions#new",     as: "login"
  post "/login",   to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: "logout"
  get "/dashboard", to: "assignments#index", as: "dashboard"
  get "/privacy", to: "pages#privacy", as: "privacy"
  get "/about", to: "pages#about", as: "about"

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
