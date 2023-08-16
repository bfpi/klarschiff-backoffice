# frozen_string_literal: true

module Citysdk
  class UsersController < CitysdkController
    include UserLogin
    before_action :check_credentials, only: :create

    # :apidoc: ### Get users
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/users.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | login | X | String | Username |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <users>
    # :apidoc:   <user>
    # :apidoc:     <id>user.id</id>
    # :apidoc:     <name>user.last_name, user.first_name</name>
    # :apidoc:     <email>user.email</email>
    # :apidoc:     <field_service_team/>
    # :apidoc:   </user>
    # :apidoc: </users>
    # :apidoc: ```
    def index
      users = find_users(params[:login], group_kind: Group.kinds[:field_service_team])
      citysdk_response(users, { root: :users, element_name: :user })
    end

    # :apidoc: ### Create users
    # :apidoc: ```
    # :apidoc: POST http://[API endpoint]/users.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | login | X | String | Username |
    # :apidoc: | password | X | String |  |
    # :apidoc: | field_service_team | X | Integer |  |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <users>
    # :apidoc:   <user>
    # :apidoc:     <id>user.id</id>
    # :apidoc:     <name>user.last_name, user.first_name</name>
    # :apidoc:     <email>user.email</email>
    # :apidoc:     <field_service_team/>
    # :apidoc:   </user>
    # :apidoc: </users>
    # :apidoc: ```
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
