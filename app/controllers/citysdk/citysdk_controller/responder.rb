# frozen_string_literal: true

module Citysdk
  class CitysdkController
    module Responder
      extend ActiveSupport::Concern

      included do
        rescue_from StandardError, with: :citysdk_respond_with_error
        rescue_from ActiveRecord::RecordInvalid, with: :citysdk_respond_with_unprocessable_entity
        rescue_from ActiveRecord::RecordNotFound, with: :citysdk_respond_with_record_not_found
      end

      def citysdk_response(objects, opts = {})
        if request.format.to_sym == :xml && !objects.respond_to?(:any?) &&
           [Citysdk::Discovery, Citysdk::Observation].exclude?(objects.class)
          objects = [objects]
        end
        respond_to do |format|
          format.html
          format.any(:xml, :json) do
            render({ request.format.to_sym => objects, dasherize: false }.merge(opts), status: opts[:status] || :ok)
          end
        end
      end

      def citysdk_respond_with_unprocessable_entity(record)
        citysdk_response [{ code: 422, description: record.to_s }], root: :error_messages, status: :unprocessable_entity
      end

      def citysdk_respond_with_record_not_found(_record)
        citysdk_response [{ code: 404, description: 'record_not_found' }], root: :error_messages, status: :not_found
      end

      def citysdk_respond_with_error(error)
        logger.info error.class
        logger.error "#{error.inspect}\n#{error.backtrace.join "\n "}"

        er = error.message.split '|'
        er = [500, error.message] if er.size == 1
        citysdk_response [{ code: er[0], description: er[1] }], root: :error_messages, status: :internal_server_error
      end
    end
  end
end
