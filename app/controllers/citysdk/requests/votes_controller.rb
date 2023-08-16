# frozen_string_literal: true

module Citysdk
  module Requests
    class VotesController < CitysdkController
      # :apidoc: ### Create new vote for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/votes/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | author | X | String | Author email |
      # :apidoc: | privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <votes>
      # :apidoc:   <vote>
      # :apidoc:     <id>vote.id</id>
      # :apidoc:   </vote>
      # :apidoc: </votes>
      # :apidoc: ```
      def create
        vote = Citysdk::Vote.new
        vote.assign_attributes(params.permit(:service_request_id, :author, :privacy_policy_accepted))
        supporter = vote.becomes_if_valid!(Supporter)
        supporter.author = vote.author
        supporter.save!

        citysdk_response vote, root: :votes, element_name: :vote, show_only_id: true, status: :created
      end

      # :apidoc: ### Confirm vote for service request
      # :apidoc: ```
      # :apidoc: PUT http://[API endpoint]/requests/votes/[confirmation_hash]/confirm.[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | confirmation_hash | X | String | generated and transmitted UUID |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <service_requests>
      # :apidoc:   <request>
      # :apidoc:     <service_request_id>request.id</service_request_id>
      # :apidoc:   </request>
      # :apidoc: </service_requests>
      # :apidoc: ```
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
