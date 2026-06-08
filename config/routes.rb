Rails.application.routes.draw do
  resources :assignments do
    member do
      patch :toggle_done
    end
  end
  get "/study_plan", to: "assignments#study_plan", as: "study_plan"
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

  get   "/password/reset",      to: "password_resets#new",    as: "new_password_reset"
  post  "/password/reset",      to: "password_resets#create"
  get   "/password/reset/edit", to: "password_resets#edit",   as: "edit_password_reset"
  patch "/password/reset",      to: "password_resets#update"
  get "/dashboard", to: "assignments#index", as: "dashboard"
  get "/privacy", to: "pages#privacy", as: "privacy"
  get "/about", to: "pages#about", as: "about"
  get "/terms", to: "pages#terms", as: "terms"

  get  "/auth/google_oauth2/callback", to: "sessions#google_callback"
  post "/auth/google_oauth2/callback", to: "sessions#google_callback"
  get  "/auth/failure", to: "sessions#auth_failure"

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
