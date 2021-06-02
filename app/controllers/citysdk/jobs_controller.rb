# frozen_string_literal: true

module Citysdk
  class JobsController < CitysdkController
    skip_before_action :validate_status

    # Neuen Auftrag anlegen
    # params:
    #   api_key             pflicht - API-Key
    #   date                pflicht - Datum
    #   status              optional - Status
    def index
      return citysdk_respond_with_unprocessable_entity(t(:date_missing)) if params[:date].blank?

      citysdk_response(jobs, root: :jobs, element_name: :job)
    end

    # Neuen Auftrag anlegen
    # params:
    #   api_key             pflicht - API-Key
    #   service_request_id  pflicht - Vorgang-ID
    #   agency_responsible  pflicht - Aussendienst-Team
    #   date                pflicht - Datum
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

    # Auftrag aktualisieren
    # params:
    #   api_key             pflicht - API-Key
    #   service_request_id  pflicht - Vorgang-ID
    #   status              pflicht - Status (CHECKED, UNCHECKED, NOT_CHECKABLE)
    #   date                pflicht - Datum
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
      jo = Citysdk::Job.where(Job.arel_table[:date].gteq(params[:date]))
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
