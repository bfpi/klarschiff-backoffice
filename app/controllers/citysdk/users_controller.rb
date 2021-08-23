# frozen_string_literal: true

module Citysdk
  class UsersController < CitysdkController
    include UserLogin
    before_action :check_credentials, only: :create

    def index
      users = find_users(params[:login], group_kind: Group.kinds[:field_service_team])
      citysdk_response(users, { root: :users, element_name: :user })
    end

    def create
      login(group_kind: Group.kinds[:field_service_team])
    end

    private
    def login_error(error)
      citysdk_respond_with_unprocessable_entity(error)
    end

    def login_success(user)
      session[:user_login] = user.login
      logger.info 'success'
      citysdk_response(user.becomes(Citysdk::User), { root: :users, element_name: :user })
    end
  end
end
