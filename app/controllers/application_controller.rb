# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :respond_with_error
  rescue_from ActiveRecord::RecordNotFound, with: :respond_with_not_found

  include ArelTable
  include Authorization

  prepend_view_path 'overlay/views'

  private

  def respond_with_error(error)
    raise if Rails.env.test?
    logger.error "#{error.inspect}\n#{error.backtrace.join "\n "}"
    ExceptionNotifier.notify_exception(error, env: request.env)
    respond_with_exception error.message
  end

  def respond_with_not_found
    raise if Rails.env.test?
    respond_with_exception I18n.t('activerecord.errors.record_not_found'), skip_internal_error_prefix: true
  end

  def respond_with_exception(message, skip_internal_error_prefix: false)
    msg = []
    msg << I18n.t(:internal_server_error) unless skip_internal_error_prefix
    msg << message.truncate(200)
    @message = msg.join(' ')
    respond_to do |format|
      format.js { render :exception, formats: :js }
      format.html { render :exception }
    end
  end

  def respond_with_forbidden(layout: 'application')
    respond_to do |format|
      format.any(:csv, :json, :xlsx, :pdf) { head :forbidden }
      format.html { render template: 'application/denied', layout:, status: :forbidden }
    end
  end
end
