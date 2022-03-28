# frozen_string_literal: true

module Citysdk
  module Requests
    class AbusesController < CitysdkController
      # Missbrauch melden
      # params:
      #   service_request_id        pflicht   - Vorgang-ID
      #   author                    pflicht   - Autor-Email
      #   comment                   pflicht   - Kommentar
      #   privacy_policy_accepted   optional  - Bestaetigung Datenschutz
      def create
        abuse = Citysdk::Abuse.new
        abuse.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        abuse.privacy_policy_accepted ||= false
        abuse_report = abuse.becomes(AbuseReport)
        abuse_report.save!

        citysdk_response abuse, root: :abuses, element_name: :abuse, show_only_id: true, status: :created
      end

      def confirm
        abuse = Citysdk::Abuse.unscoped.find_by(confirmation_hash: params[:confirmation_hash], confirmed_at: nil)
        raise ActiveRecord::RecordNotFound if abuse.blank?
        abuse_report = abuse.becomes(AbuseReport)
        abuse_report.update! confirmed_at: Time.current
        request = abuse_report.issue.becomes(Citysdk::Request)
        citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
      end
    end
  end
end
