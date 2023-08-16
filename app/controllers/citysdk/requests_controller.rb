# frozen_string_literal: true

module Citysdk
  class RequestsController < CitysdkController
    include RequestsController::Index

    before_action :encode_params, only: %i[create update]

    # :apidoc: ### Get service request
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/requests/[service_request_id].[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | - | String | API key |
    # :apidoc: | service_request_id | X | Integer | Issue ID |
    # :apidoc: | extensions | - | Boolean | Include extended attributes in response |
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
    # :apidoc:     <extended_attributes>
    # :apidoc:       <detailed_status>request.detailed_status</detailed_status>
    # :apidoc:       <media_urls>
    # :apidoc:         <media_url>request.media.url</media_url>
    # :apidoc:       </media_urls>
    # :apidoc:       <photo_required>request.photo_required</photo_required>
    # :apidoc:       <trust>request.trust</trust>
    # :apidoc:       <votes>request.votes</votes>
    # :apidoc:     </extended_attributes>
    # :apidoc:   </request>
    # :apidoc: </service_requests>
    # :apidoc: ```
    def show
      @request = Citysdk::Request.authorized(tips: authorized?(:read_tips)).where(id: params[:id])
      citysdk_response @request, root: :service_requests, element_name: :request,
        extensions: params[:extensions].try(:to_boolean),
        property_details: authorized?(:request_property_details),
        job_details: authorized?(:request_job_details)
    end

    # :apidoc: ### Create service request
    # :apidoc: ```
    # :apidoc: POST http://[API endpoint]/requests.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | email | X | String | Author email |
    # :apidoc: | service_code | X | Integer | Category ID |
    # :apidoc: | description | X | String | Description |
    # :apidoc: | lat | * | Float | Latitude value of position |
    # :apidoc: | long | * | Float | Longitude value of position |
    # :apidoc: | address_string | * | String | Address for position |
    # :apidoc: | photo_required | - | Boolean | Photo required |
    # :apidoc: | media | - | String | Photo as Base64 encoded string |
    # :apidoc: | privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |
    # :apidoc:
    # :apidoc: *: Either `lat` and `long` or `address_string` are required
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
    def create
      request = Request.new
      request.assign_attributes params.permit(:email, :service_code, :description, :lat, :long,
        :address_string, :photo_required, :media, :privacy_policy_accepted).merge(status: :pending)
      issue = request.becomes_if_valid!(Issue)
      issue.new_photo = request.new_photo if request.new_photo.present?
      issue.save!

      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true, status: :created
    end

    # :apidoc: ### Update Service request
    # :apidoc: ```
    # :apidoc: PATCH http://[API endpoint]/requests/[service_request_id].[format]
    # :apidoc: PUT   http://[API endpoint]/requests/[service_request_id].[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | email | X | String | Author email |
    # :apidoc: | service_code | X | Integer | Category ID |
    # :apidoc: | description | - | String | Description |
    # :apidoc: | lat | * | Float | Latitude value of position |
    # :apidoc: | long | * | Float | Longitude value of position |
    # :apidoc: | address_string | * | String | Address for position |
    # :apidoc: | photo_required | - | Boolean | Photo required |
    # :apidoc: | media | - | String | Photo as Base64 encoded string |
    # :apidoc: | detailed_status | - | String | CitySDK status |
    # :apidoc: | status_notes | - | String | Status note |
    # :apidoc: | priority | - | Integer | Priority |
    # :apidoc: | delegation | - | String | Delegation to external role |
    # :apidoc: | job_status | - | Integer | Job status |
    # :apidoc: | job_priority | - | Integer | Job priority |
    # :apidoc:
    # :apidoc: *: Either `lat` and `long` or `address_string` are required\
    # :apidoc: Available CitySDK states for this action: `RECEIVED`, `IN_PROCESS`, `PROCESSED`, `REJECTED`
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
    def update
      request = Request.find(params[:id])
      request.assign_attributes params.permit(:service_code, :description, :lat, :long,
        :address_string, :photo_required, :media, :detailed_status, :status_notes, :priority,
        :delegation, :job_status, :job_priority)

      issue = request.becomes(Issue)
      issue.new_photo = request.new_photo if request.new_photo.present?
      issue.save!

      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
    end

    # :apidoc: ### Confirm Service request
    # :apidoc: ```
    # :apidoc: PUT http://[API endpoint]/requests/[confirmation_hash]/confirm.[format]
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
      request = Request.find_by(status: :pending, confirmation_hash: params[:confirmation_hash])
      confirm_request(request)
      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
    end

    # :apidoc: ### Destroy Service request
    # :apidoc: ```
    # :apidoc: PUT http://[API endpoint]/requests/[confirmation_hash]/revoke.[format]
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
    def destroy
      issue = Issue.includes(:abuse_reports, :supporters).where(status: %i[pending received])
        .where(abuse_report: { issue_id: nil }).where(supporter: { issue_id: nil })
        .where(confirmation_hash: params[:confirmation_hash]).try(:first)
      raise ActiveRecord::RecordNotFound if issue.blank?
      issue.status_deleted!
      request = issue.becomes(Request)

      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
    end

    private

    def confirm_request(request)
      raise ActiveRecord::RecordNotFound if request.blank?
      Issue.transaction do
        issue = request.becomes(Issue)
        issue.status_received!
        confirm_photo(issue.confirmation_hash)
      end
    end

    def confirm_photo(confirmation_hash)
      return unless (photo = Citysdk::Photo.unscoped.find_by(confirmation_hash:))
      pho = photo.becomes(::Photo)
      pho.update!(confirmed_at: Time.current)
    end

    def encode_params
      params.each do |k, v|
        if k.in?(%w[email description address_string status_notes delegation]) && !v.is_utf8?
          params[k] = v.force_encoding('ISO-8859-1').encode('UTF-8')
        end
      end
    end
  end
end
