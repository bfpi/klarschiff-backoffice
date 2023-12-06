# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :respond_with_error
  rescue_from ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed, with: :respond_with_unprocessable_entity
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

  def respond_with_unprocessable_entity(error_or_record)
    @record = if error_or_record.is_a?(ApplicationRecord)
                error_or_record
              elsif error_or_record.respond_to?(:record)
                error_or_record.record
              else
                raise "Unknown object given for response: #{error_or_record.inspect}"
              end
    Rails.logger.info "Returned error messages: #{@record.errors.full_messages}\nfor object: #{@record.inspect}"
    render :error, status: :unprocessable_entity
  end

  def respond_with_not_found
    raise if Rails.env.test?
    respond_with_exception I18n.t('activerecord.errors.record_not_found'),
      skip_internal_error_prefix: true, status: :not_found
  end

  def respond_with_exception(message, skip_internal_error_prefix: false, status: :internal_server_error)
    msg = []
    msg << I18n.t(:internal_server_error) unless skip_internal_error_prefix
    msg << message.truncate(200)
    @message = msg.join(' ')
    respond_to do |format|
      format.js { render :exception, formats: :js, status: }
      format.html { render :exception, status: }
    end
  end

  def respond_with_forbidden(layout: 'application')
    respond_to do |format|
      format.any(:csv, :json, :xlsx, :pdf) { head :forbidden }
      format.html { render template: 'application/denied', layout:, status: :forbidden }
    end
  end
end
