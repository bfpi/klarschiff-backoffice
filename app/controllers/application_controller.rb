# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, ActiveRecord::RecordNotFound, with: :respond_with_error
  rescue_from ActiveRecord::RecordNotFound, with: :respond_with_not_found
  include Authorization

  private

  def respond_with_error(error)
    raise if Rails.env.test?

    logger.error error.inspect + error.backtrace.join("\n ")
    @message = error.message
    render :exception
  end

  def respond_with_not_found
    raise if Rails.env.test?
    @message = I18n.t(:record_not_found)
    render :exception
  end
end
