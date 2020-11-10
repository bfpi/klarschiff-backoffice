# frozen_string_literal: true

Rails.application.routes.draw do
  resource :logins, only: %i[new create update destroy] do
    get :change_user
  end
  with_options except: %i[destroy] do
    resource :dashboards, only: %i[show]
    resource :data_dependencies, only: %i[update]
    resource :infos, only: %i[show]

    resources :editorial_notifications, only: %i[index]
    resources :feedbacks, only: %i[index]
    resources :field_services
    resources :groups
    resources :issues
    resources :log_entries, only: %i[index]
    resources :mail_blacklists
    resources :places, only: %i[index]
    resources :user_ldaps, only: %i[index]
    resources :users
  end
  resources :jobs, only: %i[index update] do
    collection do
      patch :update_statuses
    end
  end

  root 'dashboards#show'
end
