# frozen_string_literal: true

class LoginsController < ApplicationController
  include UserLogin

  skip_before_action :authenticate, except: %w[change_user update]
  before_action :check_credentials, only: :create

  def create
    login
  end

  def change_user; end

  def update
    check_auth :change_user
    if params[:login] && params[:login][:user_id]
      session[:login] = User.find(params[:login][:user_id]).login
      return redirect_to root_path
    end
    render head: :unprocessable_entity
  end

  def destroy
    if session[:login].present?
      session[:login] = nil
      return redirect_to root_path
    end
    session[:auth_code] = nil
    session[:login] = nil
    session[:user_login] = nil
    redirect_to new_logins_url
  end
end
