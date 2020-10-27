# frozen_string_literal: true

Rails.application.routes.draw do
  resource :dashboards, only: %i[show]
  resource :infos, only: %i[show]
  resource :logins, only: %i[new create update destroy] do
    get :change_user
  end
  resources :editorial_notifications, only: %i[index]
  resources :groups
  resources :issues, only: %i[index]
  resources :log_entries, only: %i[index]
  resources :mail_blacklists, only: %i[index]
  resources :users
  resources :user_ldaps, only: %i[index]

  root 'dashboards#show'
end
