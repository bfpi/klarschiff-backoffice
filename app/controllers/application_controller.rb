# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :respond_with_error
  rescue_from ActiveRecord::RecordNotFound, with: :respond_with_not_found
  rescue_from UserAuthorization::NotAuthorized, with: :respond_with_not_authorized

  include Authorization

  prepend_view_path 'overlay/views'

  private

  def respond_with_error(error)
    raise if Rails.env.test?
    logger.error "#{error.inspect}\n#{error.backtrace.join "\n "}"
    @message = error.message
    render :exception
  end

  def respond_with_not_authorized
    respond_with_message(I18n.t(:not_authorized))
  end

  def respond_with_not_found
    respond_with_message(I18n.t(:record_not_found))
  end

  def respond_with_message(message)
    raise if Rails.env.test?
    @message = message
    respond_to do |format|
      format.js { render :exception, formats: :js }
      format.html { render :exception }
    end
  end
end
