# frozen_string_literal: true

module Citysdk
  module Requests
    class PhotosController < CitysdkController
      # Foto zur Meldung hinzufuegen
      # params:
      #   service_request_id        pflicht   - Vorgang-ID
      #   author                    pflicht   - Autor-Email
      #   media                     pflicht   - Foto (Base64)
      def create
        photo = Citysdk::Photo.new
        photo.assign_attributes(params.permit(:service_request_id, :author, :media))

        pho = photo.becomes(::Photo)
        pho.status = :internal
        pho.attach_media(photo.media)
        pho.save!

        citysdk_response photo, root: :photos, element_name: :photo, show_only_id: true, status: :created
      end

      def confirm
        photo = Citysdk::Photo.unscoped.find_by(confirmation_hash: params[:confirmation_hash], confirmed_at: nil)
        raise ActiveRecord::RecordNotFound if photo.blank?
        pho = photo.becomes(::Photo)
        pho.update! confirmed_at: Time.current
        request = pho.issue.becomes(Citysdk::Request)
        citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
      end
    end
  end
end
