# frozen_string_literal: true

module Citysdk
  class CitysdkController
    module ParameterValidation
      extend ActiveSupport::Concern

      included do
        private_instance_methods.select { |m| m.to_s.start_with?('validate_') }.each do |method|
          before_action method
        end
      end

      private

      def validate_dates
        %w[start_date end_date updated_after updated_before].each do |date|
          next if params[date].blank?
          y, m, d = params[date].split '-'
          next if Date.valid_date? y.to_i, m.to_i, d.to_i
          raise "date #{date} invalid"
        end
      end

      def validate_keyword
        return unless (keyword = params[:keyword]).present? && %w[problem idea].exclude?(keyword)
        raise 'keyword invalid'
      end

      def validate_status
        return unless params[:status].present? && !Citysdk::Status.valid_filter_values(params[:status])
        raise 'status invalid'
      end

      def validate_detailed_status
        return unless params[:detailed_status].present? && !Citysdk::Status.valid_filter_values(
          params[:detailed_status], :citysdk
        )
        raise 'status invalid'
      end

      def validate_service_request_id
        return unless (ids = params[:service_request_id]).present? && !ids.i?
        return if ids.present? && ids.include?(',') && ids.split(',').all? do |e|
                    e =~ /^\d+$/
                  end
        raise 'service_request_id is not a number'
      end
    end
  end
end
