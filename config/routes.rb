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

    resources :delegations, only: %i[index edit show update]
    resources :dms, only: %i[index show]
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
  resources :editorial_notifications, only: %i[index new create edit update destroy]
  resources :jobs, only: %i[index update destroy] do
    collection do
      post :assign
      put :change_order
      put :update_dates
      put :update_statuses
    end
  end
  resources :responsibilities

  namespace :citysdk do
    get 'coverage' => 'coverage#valid'
    resources :areas, only: %i[index]
    resources :discovery, only: %i[index]
    resources :jobs, only: %i[index create update]
    resources :observations, only: %i[create]
    resources :requests, except: %i[destroy]
    resources :services, only: %i[index show]
    put 'requests/:confirmation_hash/confirm' => 'requests#confirm'
    put 'requests/:confirmation_hash/revoke' => 'requests#destroy'

    namespace :requests do
      put 'abuses/:confirmation_hash/confirm' => 'abuses#confirm'
      post 'abuses/:service_request_id' => 'abuses#create', as: :abuses

      get   'comments/:service_request_id' => 'comments#index'
      post  'comments/:service_request_id' => 'comments#create', as: :comments

      put 'photos/:confirmation_hash/confirm' => 'photos#confirm'
      post 'photos/:service_request_id' => 'photos#create', as: :photos

      get   'notes/:service_request_id'    => 'notes#index'
      post  'notes/:service_request_id'    => 'notes#create', as: :notes

      put 'votes/:confirmation_hash/confirm' => 'votes#confirm'
      post 'votes/:service_request_id' => 'votes#create', as: :votes
    end
  end

  root 'dashboards#show'
end
