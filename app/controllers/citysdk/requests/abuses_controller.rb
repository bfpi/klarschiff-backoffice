# frozen_string_literal: true

module Citysdk
  module Requests
    class AbusesController < CitysdkController
      # :apidoc: ### Create new abuse for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/abuses/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | author | X | String | Author email |
      # :apidoc: | comment | X | String | |
      # :apidoc: | privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <abuses>
      # :apidoc:   <abuse>
      # :apidoc:     <id>abuse.id</id>
      # :apidoc:   </abuse>
      # :apidoc: </abuses>
      # :apidoc: ```
      def create
        abuse = Citysdk::Abuse.new
        abuse.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        abuse_report = abuse.becomes_if_valid!(AbuseReport)
        abuse_report.save!

        citysdk_response abuse, root: :abuses, element_name: :abuse, show_only_id: true, status: :created
      end

      # :apidoc: ### Confirm abuse for service request
      # :apidoc: ```
      # :apidoc: PUT http://[API endpoint]/requests/abuses/[confirmation_hash]/confirm.[format]
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
