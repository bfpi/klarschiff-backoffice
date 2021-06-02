# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :respond_with_error
  rescue_from ActiveRecord::RecordNotFound, with: :respond_with_not_found

  include Authorization

  prepend_view_path 'overlay/views'

  private

  def respond_with_error(error)
    raise if Rails.env.test?
    logger.error "#{error.inspect}\n#{error.backtrace.join "\n "}"
    respond_with_execption error.message
  end

  def respond_with_not_found
    raise if Rails.env.test?
    respond_with_execption I18n.t('activerecord.errors.record_not_found')
  end

  def respond_with_execption(message)
    @message = message
    respond_to do |format|
      format.js { render :exception, formats: :js }
      format.html { render :exception }
    end
  end
end
