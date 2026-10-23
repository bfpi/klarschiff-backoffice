# frozen_string_literal: true

module Citysdk
  module Requests
    class PhotosController < CitysdkController
      # :apidoc: ### Create new photo for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/photos/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | author | X | String | Author email |
      # :apidoc: | media | X | String / Array | Photo as Base64 encoded string, multiple photos as array of strings |
      # :apidoc:
      # :apidoc: Multiple photos can be sent as array, e.g. `media[]=...&media[]=...` or as JSON array.
      # :apidoc: Blank entries are ignored. The request is rejected if any of the photos is invalid.
      # :apidoc: Every photo has to be confirmed separately, the author receives one email per photo.
      # :apidoc:
      # :apidoc: If media is sent as array, the response contains one `photo` element per photo (JSON: array).
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <photos>
      # :apidoc:   <photo>
      # :apidoc:     <id>photo.id</id>
      # :apidoc:   </photo>
      # :apidoc: </photos>
      # :apidoc: ```
      def create
        attributes = params.permit(:service_request_id, :author, :media, media: [])
        photos = create_photos(attributes, Array.wrap(attributes[:media]).compact_blank)
        photos = photos.first unless attributes[:media].is_a?(Array) # single string: keep previous response format

        citysdk_response photos, root: :photos, element_name: :photo, show_only_id: true, status: :created
      end

      # :apidoc: ### Confirm photo for service request
      # :apidoc: ```
      # :apidoc: PUT http://[API endpoint]/requests/photos/[confirmation_hash]/confirm.[format]
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
        photo = Citysdk::Photo.unscoped.find_by(confirmation_hash: params[:confirmation_hash], confirmed_at: nil)
        raise ActiveRecord::RecordNotFound if photo.blank?
        pho = photo.becomes(::Photo)
        pho.update! confirmed_at: Time.current
        request = pho.issue.becomes(Citysdk::Request)
        citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
      end

      private

      def create_photos(attributes, media)
        photos = build_photos(attributes, media)
        photos.each(&:validate!)
        ::Photo.transaction { photos.each(&:save!) }
        photos.map { |photo| photo.becomes(Citysdk::Photo) }
      end

      def build_photos(attributes, media)
        (media.presence || [nil]).map do |value|
          photo = Citysdk::Photo.new
          photo.assign_attributes(attributes.merge(media: value))

          pho = photo.becomes(::Photo)
          pho.status = :internal
          pho.attach_media(photo.media)
          pho
        end
      end
    end
  end
end
