# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    rescue_from UserAuthorization::NotAuthorized, with: -> { respond_with_forbidden }

    before_action :authenticate

    helper_method :authorized?, :authorized_for_administration?
  end

  private

  def authorized?(action, object = nil, user = Current.user)
    if params[:api_key]
      return (client = current_citysdk_client) && client[:permissions].try(:include?,
        action)
    end
    user&.authorized?(action, object)
  end

  def init_current_login
    Current.login = session[:user_login]
    return session[:login] if session[:login].present?
    redirect_to new_logins_path unless Current.login
    Current.login
  end

  def authenticate
    return check_citysdk_authentication if controller_path.starts_with?('citysdk')
    login = init_current_login or return
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

  def check_citysdk_authentication
    case controller_path
    when 'citysdk/requests/notes'
      check_citysdk_authentication_for_notes
    when 'citysdk/requests/comments'
      check_citysdk_authentication_for_comments
    when 'citysdk/requests'
      check_citysdk_authentication_for_requests
    when 'citysdk/jobs'
      check_citysdk_authentication_for_jobs
    end
  end

  def check_citysdk_authentication_for_notes
    check_citysdk_action_permission(:read_notes) if action_name == 'index'
    check_citysdk_action_permission(:create_notes) if action_name == 'create'
  end

  def check_citysdk_authentication_for_comments
    check_citysdk_action_permission(:read_comments) if action_name == 'index'
    check_citysdk_action_permission(:create_comments) if action_name == 'create'
  end

  def check_citysdk_authentication_for_requests
    check_citysdk_action_permission(:create_requests) if action_name == 'create'
    check_citysdk_action_permission(:update_requests) if action_name == 'update'
  end

  def check_citysdk_authentication_for_jobs
    check_citysdk_action_permission(:update_jobs)
  end

  def check_citysdk_action_permission(action)
    raise Citysdk::NotAuthorized, "400|#{t('api_key.missing')}" if params[:api_key].blank?
    return true if (client = current_citysdk_client) && client[:permissions].try(:include?, action)
    raise Citysdk::NotAuthorized, "403|#{t('api_key.no_permision')}"
  end

  def current_citysdk_client(skip_raise: false)
    raise Citysdk::NotAuthorized, "400|#{t('api_key.missing')}" if params['api_key'].blank? && !skip_raise

    key = params['api_key']
    raise Citysdk::NotAuthorized, "401|#{t('api_key.invalid')}" if Client[key].blank? && !skip_raise

    Client[key]
  end

  def respond_with_forbidden(layout: 'application')
    raise if Rails.env.test?
    respond_to do |format|
      format.any(:csv, :json, :xlsx, :pdf) { head :forbidden }
      format.html { render template: 'application/denied', layout: layout, status: :forbidden }
    end
  end
end
