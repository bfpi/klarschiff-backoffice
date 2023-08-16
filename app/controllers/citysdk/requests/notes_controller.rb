# frozen_string_literal: true

module Citysdk
  module Requests
    class NotesController < CitysdkController
      # :apidoc: ### Get notes list for service request
      # :apidoc: ```
      # :apidoc: GET http://[API endpoint]/requests/notes/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Notes are internal comments on issues.
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | api_key | X | String | API key |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <notes type="array">
      # :apidoc:   <note>
      # :apidoc:     <jurisdiction_id></jurisdiction_id>
      # :apidoc:     <comment>note.text</comment>
      # :apidoc:     <datetime>note.datetime</datetime>
      # :apidoc:     <service_request_id>note.service_request_id</service_request_id>
      # :apidoc:     <author>note.author</author>
      # :apidoc:   </note>
      # :apidoc: </notes>
      # :apidoc: ```
      def index
        notes = Citysdk::Note.where(issue_id: params[:service_request_id])
        citysdk_response notes, root: :notes, element_name: :note
      end

      # :apidoc: ### Create new note for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/notes/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Notes are internal comments on issues.
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | api_key | X | String | API key |
      # :apidoc: | author | X | String | Author email |
      # :apidoc: | note | X | String | Internal comment for issue |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <notes>
      # :apidoc:   <note>
      # :apidoc:     <jurisdiction_id></jurisdiction_id>
      # :apidoc:     <comment>note.text</comment>
      # :apidoc:     <datetime>note.datetime</datetime>
      # :apidoc:     <service_request_id>note.service_request_id</service_request_id>
      # :apidoc:     <author>note.author</author>
      # :apidoc:   </note>
      # :apidoc: </notes>
      # :apidoc: ```
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
