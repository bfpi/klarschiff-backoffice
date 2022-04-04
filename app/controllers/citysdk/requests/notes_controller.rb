# frozen_string_literal: true

module Citysdk
  module Requests
    class NotesController < CitysdkController
      # interne Kommentare
      #   service_request_id  pflicht  - Vorgang-ID
      #   api_key             pflicht  - API-Key
      def index
        notes = Citysdk::Note.where(issue_id: params[:service_request_id])
        citysdk_response notes, root: :notes, element_name: :note
      end

      # internen Kommentar anlegen
      # params:
      #   service_request_id  pflicht  - Vorgang-ID
      #   api_key             pflicht  - API-Key
      #   author              pflicht  - Autor-Email
      #   note             pflicht  - Kommentar
      def create
        note = Citysdk::Note.new
        note.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        comment = note.becomes_if_valid!(::Comment)
        comment.save!

        citysdk_response note, root: :notes, element_name: :note, show_only_id: true, status: :created
      end
    end
  end
end
