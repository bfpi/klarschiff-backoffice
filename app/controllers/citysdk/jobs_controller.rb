# frozen_string_literal: true

module Citysdk
  class JobsController < CitysdkController
    skip_before_action :validate_status

    # :apidoc: ### Get jobs list
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/jobs.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | date | X | Date | Filter jobs that are the equal or lower than the given date |
    # :apidoc: | status | - | String | Job status |
    # :apidoc:
    # :apidoc: Available job states for this action: `CHECKED`, `UNCHECKED`, `NOT_CHECKABLE`
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <jobs>
    # :apidoc:   <job>
    # :apidoc:     <id>job.id</id>
    # :apidoc:     <service-request-id>job.service_request_id</service-request-id>
    # :apidoc:     <date>job.date</date>
    # :apidoc:     <agency-responsible>job.agency_responsible</agency-responsible>
    # :apidoc:     <status>job.status</status>
    # :apidoc:   </job>
    # :apidoc:   ...
    # :apidoc: </jobs>
    # :apidoc: ```
    def index
      return citysdk_respond_with_unprocessable_entity(t(:date_missing)) if params[:date].blank?

      citysdk_response(jobs, root: :jobs, element_name: :job)
    end

    # :apidoc: ### Create new job
    # :apidoc: ```
    # :apidoc: POST http://[API endpoint]/jobs.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | service_request_id | X | Integer | Affected issue ID |
    # :apidoc: | agency_responsible | X | String | Name of team |
    # :apidoc: | date | X | Date | Date for job |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <jobs>
    # :apidoc:   <job>
    # :apidoc:     <id>job.id</id>
    # :apidoc:     <service-request-id>job.service_request_id</service-request-id>
    # :apidoc:     <date>job.date</date>
    # :apidoc:     <agency-responsible>job.agency_responsible</agency-responsible>
    # :apidoc:     <status>job.status</status>
    # :apidoc:   </job>
    # :apidoc: </jobs>
    # :apidoc: ```
    def create
      job = Citysdk::Job.new
      job.status = :unchecked
      job.assign_attributes(params.permit(:service_request_id, :agency_responsible, :date))

      jo = job.becomes(::Job)
      jo.save!
      issue = Issue.find(params[:service_request_id])
      issue.job = jo
      issue.save!

      citysdk_response issue.job.becomes(Citysdk::Job), root: :jobs, element_name: :job, status: :created
    end

    # :apidoc: ### Update job
    # :apidoc: ```
    # :apidoc: PATCH http://[API endpoint]/jobs/[service_request_id].[format]
    # :apidoc: PUT   http://[API endpoint]/jobs/[service_request_id].[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | service_request_id | X | Integer | Affected issue ID |
    # :apidoc: | status | X | String | Job status |
    # :apidoc: | date | X | Date | Date of job |
    # :apidoc:
    # :apidoc: Available job states for this action: `CHECKED`, `UNCHECKED`, `NOT_CHECKABLE`
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <jobs>
    # :apidoc:   <job>
    # :apidoc:     <id>job.id</id>
    # :apidoc:     <service-request-id>job.service_request_id</service-request-id>
    # :apidoc:     <date>job.date</date>
    # :apidoc:     <agency-responsible>job.agency_responsible</agency-responsible>
    # :apidoc:     <status>job.status</status>
    # :apidoc:   </job>
    # :apidoc: </jobs>
    # :apidoc: ```
    def update
      issue = Issue.find(params[:id])
      raise ActiveRecord::RecordNotFound unless issue.job
      job = issue.job.becomes(Citysdk::Job)

      job.assign_attributes(update_params)
      jo = job.becomes(::Job)
      jo.save!

      citysdk_response job, root: :jobs, element_name: :job, status: :created
    end

    private

    def jobs
      jo = Citysdk::Job.where(job_arel_table[:date].gteq(params[:date]))
      jo = jo.where(status: params[:status]) if params[:status].present?
      jo
    end

    def update_params
      par = params.permit(:status, :date)
      par[:status] = par[:status].blank? ? nil : par[:status].downcase.to_sym
      par[:date] = nil if par[:date].blank?
      par
    end
  end
end
