Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users
end
