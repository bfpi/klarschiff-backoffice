# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :respond_with_error

  include Authorization

  private

  def respond_with_error(error)
    raise if Rails.env.test?

    logger.error error.inspect + error.backtrace.join("\n ")

    @error = error
    render :exception
  end
end
