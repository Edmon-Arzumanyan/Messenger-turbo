# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'chats#index'

  devise_for :users
  resources :chats, except: %i[edit update] do
    resources :messages
  end
end
