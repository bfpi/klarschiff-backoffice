# frozen_string_literal: true

module Citysdk
  module Requests
    class CompletionsController < CitysdkController
      # :apidoc: ### Create new completion for service request
      # :apidoc: <code>POST http://[API endpoint]/requests/completions/[service_request_id].[format]</code>
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
        completion = Citysdk::Completion.new
        completion.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        completion = completion.becomes_if_valid!(::Completion)
        completion.status = 'open'
        completion.save!

        citysdk_response completion, root: :completions, element_name: :completion, show_only_id: true, status: :created
      end

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
