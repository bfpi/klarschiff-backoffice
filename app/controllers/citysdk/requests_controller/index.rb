# frozen_string_literal: true

module Citysdk
  class RequestsController < CitysdkController
    module Index
      extend ActiveSupport::Concern

      # :apidoc: ### Get service requests list
      # :apidoc: ```
      # :apidoc: GET http://[API endpoint]/requests.[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | api_key | - | String | API key |
      # :apidoc: | service_request_id | - | Integer / String | List of multiple Request-IDs, comma delimited |
      # :apidoc: | service_code | - | Integer | ID of category |
      # :apidoc: | status | - | String | Filter issues by Open311 status, default = `open` |
      # :apidoc: | detailed_status |  - | String | Filter issues by CitySDK status |
      # :apidoc: | start_date | - | Date | Filter for issue date >= value, e.g 2011-01-01T00:00:00Z |
      # :apidoc: | end_date | - | Date | Filter for isse date <= value, e.g 2011-01-01T00:00:00Z |
      # :apidoc: | updated_after | - | Date | Filter for issue version >= value, e.g 2011-01-01T00:00:00Z |
      # :apidoc: | updated_before | - | Date | Filter for issue version <= value, e.g 2011-01-01T00:00:00Z |
      # :apidoc: | agency_responsible | - | String | Filter for issues by job team |
      # :apidoc: | extensions | - | Boolean | Include extended attributs in response |
      # :apidoc: | lat | - | Double | Filter restriction area (lat, long and radius required) |
      # :apidoc: | long | - | Double | Filter restriction area (lat, long and radius required) |
      # :apidoc: | radius | - | Double | Meter to filter restriction area (lat, long and radius required) |
      # :apidoc: | keyword | - | String | Filter issues by kind, options: problem, idea, tip |
      # :apidoc: | with_picture | - | Boolean | Filter issues with released photos |
      # :apidoc: | also_archived | - | Boolean | Include already archived issues |
      # :apidoc: | just_count | - | Boolean | Switch response to only return amount of affected issues |
      # :apidoc: | max_requests | - | Integer | Maximum number of requests to return |
      # :apidoc: | observation_key | - | String | UUID of observed area to use as filter |
      # :apidoc: | area_code | - | Integer | Filter issues by affected area ID |
      # :apidoc:
      # :apidoc: Available Open311 states for this action: `open`, `closed`\
      # :apidoc: Available CitySDK states for this action: `PENDING`, `RECEIVED`, `IN_PROCESS`, `PROCESSED`, `REJECTED`
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <service_requests type="array">
      # :apidoc:   <request>
      # :apidoc:     <service_request_id>request.id</service_request_id>
      # :apidoc:     <status_notes/>
      # :apidoc:     <status>request.status</status>
      # :apidoc:     <service_code>request.service.code</service_code>
      # :apidoc:     <service_name>request.service.name</service_name>
      # :apidoc:     <description>request.description</description>
      # :apidoc:     <agency_responsible>request.agency_responsible</agency_responsible>
      # :apidoc:     <service_notice/>
      # :apidoc:     <requested_datetime>request.requested_datetime</requested_datetime>
      # :apidoc:     <updated_datetime>request.updated_datetime</updated_datetime>
      # :apidoc:     <expected_datetime/>
      # :apidoc:     <address>request.address</address>
      # :apidoc:     <adress_id/>
      # :apidoc:     <lat>request.position.lat</lat>
      # :apidoc:     <long>request.position.lat</long>
      # :apidoc:     <media_url/>
      # :apidoc:     <zipcode/>
      # :apidoc:   </request>
      # :apidoc: </service_requests>
      # :apidoc: ```
      def index
        return index_just_counts if params[:just_count].present?

        citysdk_response filtered_requests, root: :service_requests, element_name: :request,
          extensions: params[:extensions].try(:to_boolean),
          property_details: authorized?(:request_property_details),
          job_details: authorized?(:request_job_details)
      end

      private

      def index_just_counts
        citysdk_response [{ count: filtered_requests.count }], root: :service_requests
      end

      def filtered_requests
        Citysdk::RequestFilter.new(params, tips: authorized?(:read_tips)).collection
      end
    end
  end
end
