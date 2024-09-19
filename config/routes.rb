# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'chats#index'

  devise_for :users
  resources :chats, except: %i[edit update] do
    resources :messages
    get 'reply-message/:id', to: 'messages#reply', as: 'reply_message'
  end

  namespace :admin do
    root 'users#index'

    resources :users do
      patch :toggle_activation, on: :member
    end

    resources :chats do
      patch :toggle_activation, on: :member
    end

    resources :messages do
      patch :toggle_activation, on: :member
    end
  end
end
