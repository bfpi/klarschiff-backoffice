# frozen_string_literal: true

class LoginsController < ApplicationController
  skip_before_action :authenticate, except: %w[change_user update]
  before_action :check_credentials, only: :create

  def create
    user = login_user(@credentials[:login])
    if user&.ldap.present? && Ldap.login(user.ldap, @credentials[:password]) ||
       user&.authenticate(@credentials[:password])
      return login_success(user)
    end
    login_error 'Login oder Passwort sind nicht korrekt'
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
    if session[:login] != session[:user_login]
      session[:login] = session[:user_login]
      return redirect_to root_path
    end
    session[:login] = nil
    session[:user_login] = nil
    redirect_to new_logins_url
  end

  private

  def login_error(error)
    @error = error
    logger.info error
    render :new
  end

  def login_success(user)
    session[:user_login] = user.login
    redirect_to root_url
  end

  def login_user(login)
    User.active.find_by(User.arel_table[:login].matches(login).or(User.arel_table[:email].matches(login)))
  end

  def check_credentials
    @credentials = params.require(:login).permit(:login, :password)
    return if @credentials.values.none?(&:blank?)
    login_error 'Login und Passwort müssen angegeben werden'
  end
end
