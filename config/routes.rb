# frozen_string_literal: true

Rails.application.routes.draw do
  resource :logins, only: %i[new create update destroy] do
    get :change_user
  end
  with_options except: %i[destroy] do
    resource :contacts, only: %i[show]
    resource :dashboards, only: %i[show]
    resource :data_dependencies, only: %i[update]
    resource :imprints, only: %i[show]
    resource :infos, only: %i[show]

    resources :delegations, only: %i[index edit update]
    resources :editorial_notifications, only: %i[index]
    resources :feedbacks, only: %i[index]
    resources :field_services
    resources :groups
    resources :issues do
      resource :issue_email, only: %i[new create show]
      resources :issue_exports, only: %i[create], defaults: { format: :pdf }
    end
    resources :log_entries, only: %i[index]
    resources :mail_blacklists
    resources :places, only: %i[index]
    resources :user_ldaps, only: %i[index]
    resources :users
    resources :tests, only: %i[index create]
  end
  resources :abuse_reports, only: %i[create update]
  resources :comments, only: %i[create edit update show destroy]
  resources :jobs, only: %i[index update destroy] do
    collection do
      put :update_dates
      put :update_statuses
      put :change_order
    end
  end
  resources :responsibilities

  root 'dashboards#show'
end
