# frozen_string_literal: true

class LoginsController < ApplicationController
  skip_before_action :authenticate, except: %w[change_user update]

  def create
    login_params = params.require(:login).permit(:login, :password)
    return login_error('Login und Passwort müssen angegeben werden') if login_params.values.any?(&:blank?)
    user = login_user(login_params)
    if user&.ldap.present?
      return login_error('Login oder Passwort sind nicht korrekt') unless Ldap.login(user.ldap, login_params[:password])
    else
      return login_error('Login oder Passwort sind nicht korrekt') unless user&.authenticate(login_params[:password])
    end
    login_success user
  end

  def change_user; end

  def update
    return respond_with_forbidden unless Current.user.authorized?(:change_user)
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

  def login_user(login_params)
    User.active.find_by(User.arel_table[:login].matches(login_params[:login]).or(
                          User.arel_table[:email].matches(login_params[:login])
                        ))
  end
end
