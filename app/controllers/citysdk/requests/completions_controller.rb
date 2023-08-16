# frozen_string_literal: true

module Citysdk
  module Requests
    class CompletionsController < CitysdkController
      # :apidoc: ### Create new completion for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/completions/[service_request_id].[format]
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
      # :apidoc: <completions>
      # :apidoc:   <completion>
      # :apidoc:     <id>completion.id</id>
      # :apidoc:   </completion>
      # :apidoc: </completions>
      # :apidoc: ```
      def create
        citysdk_completion = Citysdk::Completion.new
        citysdk_completion.assign_attributes(params.permit(:service_request_id, :author, :privacy_policy_accepted))
        completion = citysdk_completion.becomes_if_valid!(::Completion)
        completion.status = :open
        completion.save!

        citysdk_response citysdk_completion, root: :completions, element_name: :completion,
          show_only_id: true, status: :created
      end

      # :apidoc: ### Confirm completion for service request
      # :apidoc: ```
      # :apidoc: PUT [API endpoint]/requests/completions/[confirmation_hash]/confirm.[format]
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
        completion = Citysdk::Completion.unscoped.find_by(
          confirmation_hash: params[:confirmation_hash], confirmed_at: nil
        )
        raise ActiveRecord::RecordNotFound if completion.blank?
        completion = completion.becomes(::Completion)
        completion.update! confirmed_at: Time.current
        request = completion.issue.becomes(Citysdk::Request)
        citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
      end
    end
  end
end
