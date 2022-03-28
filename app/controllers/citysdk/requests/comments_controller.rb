# frozen_string_literal: true

module Citysdk
  module Requests
    class CommentsController < CitysdkController
      # Lob/Hinweis/Kritik
      #   service_request_id  pflicht  - Vorgang-ID
      #   api_key             pflicht  - API-Key
      def index
        comments = Citysdk::Comment.where(issue_id: params[:service_request_id])
        citysdk_response comments, root: :comments, element_name: :comment
      end

      # Lob/Hinweis/Kritik anlegen
      # params:
      #   service_request_id        pflicht  - Vorgang-ID
      #   api_key                   pflicht  - API-Key
      #   author                    pflicht  - Autor-Email
      #   comment                   pflicht  - Kommentar
      #   privacy_policy_accepted   optional - Bestaetigung Datenschutz
      def create
        comment = Citysdk::Comment.new
        comment.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        comment.privacy_policy_accepted ||= false
        comment_report = comment.becomes(Feedback)
        comment_report.save!

        citysdk_response comment, root: :comments, element_name: :comment, show_only_id: true, status: :created
      end
    end
  end
end
