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
    return authenticate_with_auth_code if (session[:auth_code] || params[:auth_code]).present?
    return authenticate_with_user_uuid if params[:user_uuid].present?
    login = init_current_login or return
    authenticate_user login
  end

  def authenticate_user(login)
    if (Current.user = User.active.find_by(case_insensitive_comparision(:login, login)))
      logger_current_user login
    else
      redirect_to new_logins_path
    end
  end

  def authenticate_with_auth_code
    reset_session_user
    session[:auth_code] = params[:auth_code] if params[:auth_code].present?
    init_current_user_with_auth_code
    return logger_current_user(Current.login) if Current.user.auth_code
    redirect_to new_logins_path
  end

  def authenticate_with_user_uuid
    return unless controller_path.eql?('issues_rss')
    Current.user = User.find_by(uuid: params[:user_uuid])
  end

  def init_current_user_with_auth_code
    Current.login = session[:auth_code]
    Current.user = User.new(login: Current.login)
    Current.user.auth_code = (ac = AuthCode.find_by(uuid: Current.login))
    Current.user.group_ids << ac.group_id if ac
  end

  def reset_session_user
    session[:user_login] = nil
    Current.login = nil
  end

  def logger_current_user(login)
    msg = "Username: #{Current.login}"
    msg += " as #{login}" unless login.casecmp(Current.login.downcase).zero?
    logger.info msg
  end

  def check_auth(action, object = nil)
    raise UserAuthorization::NotAuthorized, action unless authorized?(action, object)
  end

  def check_citysdk_authentication
    current_user
    case controller_path
    when 'citysdk/requests/notes' then check_citysdk_authentication_for_notes
    when 'citysdk/requests/comments' then check_citysdk_authentication_for_comments
    when 'citysdk/requests' then check_citysdk_authentication_for_requests
    when 'citysdk/jobs' then check_citysdk_authentication_for_jobs
    when 'citysdk/users' then check_citysdk_authentication_for_user_login
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

  def check_citysdk_authentication_for_user_login
    check_citysdk_action_permission(:user_login)
  end

  def check_citysdk_action_permission(action)
    raise Citysdk::NotAuthorized, "400|#{t('api_key.missing')}" if params[:api_key].blank?
    return true if (client = current_citysdk_client) && client[:permissions].try(:include?, action)
    raise Citysdk::NotAuthorized, "403|#{t('api_key.no_permision')}"
  end

  def current_user
    Current.email = params[:email].presence
    return if !trust_email_for_user_identification? || Current.email.blank?
    Current.user = User.active.find_by(case_insensitive_comparision(:email, params[:email]))
  end

  def current_citysdk_client(skip_raise: false)
    raise Citysdk::NotAuthorized, "400|#{t('api_key.missing')}" if params['api_key'].blank? && !skip_raise

    key = params['api_key']
    raise Citysdk::NotAuthorized, "401|#{t('api_key.invalid')}" if Client[key].blank? && !skip_raise

    Client[key]
  end

  def trust_email_for_user_identification?
    params['api_key'].present? && current_citysdk_client[:trust_email_for_user_identification].present?
  end
end
