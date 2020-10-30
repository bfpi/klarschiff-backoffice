# frozen_string_literal: true

Rails.application.routes.draw do
  with_options except: %i[destroy] do
    resource :dashboards, only: %i[show]
    resource :data_dependencies, only: %i[update]
    resource :infos, only: %i[show]
    resource :logins, only: %i[new create update destroy] do
      get :change_user
    end

    resources :editorial_notifications, only: %i[index]
    resources :feedbacks, only: %i[index]
    resources :groups
    resources :issues
    resources :jobs, only: %i[index]
    resources :log_entries, only: %i[index]
    resources :mail_blacklists, only: %i[index]
    resources :user_ldaps, only: %i[index]
    resources :users
  end

  root 'dashboards#show'
end
