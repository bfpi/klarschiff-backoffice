# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate

  private

  def authenticate
    if (Current.user = User.active.find_by(User.arel_table[:login].matches(session[:login])))
      logger.info "Username: #{Current.user&.login}"
    else
      redirect_to new_logins_path
    end
  end
end
