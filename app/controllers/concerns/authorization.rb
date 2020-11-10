# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authenticate

    helper_method :authorized?, :authorized_for_administration?
  end

  private

  def authorized?(action, object = nil, user = Current.user)
    user&.authorized?(action, object)
  end

  def init_current_login
    Current.login = session[:user_login]
    redirect_to new_logins_path unless Current.login
    Current.login
  end

  def authenticate
    init_current_login or return
    login = session[:login].presence || Current.login
    if (Current.user = User.active.find_by(User.arel_table[:login].matches(login)))
      logger_current_user login
    else
      redirect_to new_logins_path
    end
  end

  def logger_current_user(login)
    msg = "Username: #{Current.login}"
    msg += " as #{login}" unless login.casecmp(Current.login.downcase).zero?
    logger.info msg
  end

  def check_auth(action)
    raise UserAuthorization::NotAuthorized, action unless authorized?(action)
  end
end
