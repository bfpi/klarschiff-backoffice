# frozen_string_literal: true

module Citysdk
  module Requests
    class VotesController < CitysdkController
      # Unterstuetzung melden
      # params:
      #   service_request_id        pflicht   - Vorgang-ID
      #   author                    pflicht   - Autor-Email
      #   privacy_policy_accepted   optional  - Bestaetigung Datenschutz
      def create
        vote = Citysdk::Vote.new
        vote.assign_attributes(params.permit(:service_request_id, :author, :privacy_policy_accepted))

        supporter = vote.becomes(Supporter)
        supporter.author = vote.author
        supporter.save!

        citysdk_response vote, root: :votes, element_name: :vote, show_only_id: true, status: :created
      end

      def confirm
        vote = Citysdk::Vote.unscoped.find_by(confirmation_hash: params[:confirmation_hash], confirmed_at: nil)
        raise ActiveRecord::RecordNotFound if vote.blank?
        supporter = vote.becomes(Supporter)
        supporter.update! confirmed_at: Time.current
        request = supporter.issue.becomes(Citysdk::Request)
        citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
      end
    end
  end
end
