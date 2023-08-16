# frozen_string_literal: true

module Citysdk
  module Requests
    class CommentsController < CitysdkController
      # :apidoc: ### Get comments list for service request
      # :apidoc: ```
      # :apidoc: GET http://[API endpoint]/requests/comments/[service_request_id].[format]
      # :apidoc: ```
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
      # :apidoc: <comments type="array">
      # :apidoc:   <comment>
      # :apidoc:     <id>comment.id</id>
      # :apidoc:     <jurisdiction_id></jurisdiction_id>
      # :apidoc:     <comment>comment.text</comment>
      # :apidoc:     <datetime>comment.datetime</datetime>
      # :apidoc:     <service_request_id>comment.service_request_id</service_request_id>
      # :apidoc:   </comment>
      # :apidoc: </comments>
      # :apidoc: ```
      def index
        comments = Citysdk::Comment.where(issue_id: params[:service_request_id])
        citysdk_response comments, root: :comments, element_name: :comment
      end

      # :apidoc: ### Create new comment for service request
      # :apidoc: ```
      # :apidoc: POST http://[API endpoint]/requests/comments/[service_request_id].[format]
      # :apidoc: ```
      # :apidoc:
      # :apidoc: Parameters:
      # :apidoc:
      # :apidoc: | Name | Required | Type | Notes |
      # :apidoc: |:--|:-:|:--|:--|
      # :apidoc: | service_request_id | X | Integer | Issue ID |
      # :apidoc: | api_key | X | String | API key |
      # :apidoc: | author | X | String | Author email |
      # :apidoc: | comment | X | String | |
      # :apidoc: | privacy_policy_accepted | - | Boolean | Confirmation of accepted privacy policy |
      # :apidoc:
      # :apidoc: Sample Response:
      # :apidoc:
      # :apidoc: ```xml
      # :apidoc: <comments>
      # :apidoc:   <comment>
      # :apidoc:     <id>comment.id</id>
      # :apidoc:     <jurisdiction_id></jurisdiction_id>
      # :apidoc:     <comment>comment.text</comment>
      # :apidoc:     <datetime>comment.datetime</datetime>
      # :apidoc:     <service_request_id>comment.service_request_id</service_request_id>
      # :apidoc:   </comment>
      # :apidoc: </comments>
      # :apidoc: ```
      def create
        comment = Citysdk::Comment.new
        comment.assign_attributes(params.permit(:service_request_id, :author, :comment, :privacy_policy_accepted))
        comment_report = comment.becomes_if_valid!(Feedback)
        comment_report.save!

        citysdk_response comment, root: :comments, element_name: :comment, show_only_id: true, status: :created
      end
    end
  end
end
