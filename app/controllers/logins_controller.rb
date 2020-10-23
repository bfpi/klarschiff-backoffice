# frozen_string_literal: true

class LoginsController < ApplicationController
  skip_before_action :authenticate

  def create
    login_params = params.require(:login).permit(:login, :password)
    return login_error('Login und Passwort müssen angegeben werden') if login_params.values.any?(&:blank?)
    user = login_user(login_params)
    if user.ldap
      unless Ldap.login(login_params[:login], login_params[:password])
        return login_error('Login oder Passwort sind nicht korrekt')
      end
    else
      return login_error('Login oder Passwort sind nicht korrekt') unless user&.authenticate(login_params[:password])
    end
    login_success user
  end

  def destroy
    session[:login] = nil
    redirect_to new_logins_url
  end

  private

  def login_error(error)
    @error = error
    logger.info error
    render :new
  end

  def login_success(user)
    session[:login] = user.login
    redirect_to root_url
  end

  def login_user(login_params)
    User.active.find_by(User.arel_table[:login].matches(login_params[:login]).or(
                          User.arel_table[:email].matches(login_params[:login])
                        ))
  end
end
