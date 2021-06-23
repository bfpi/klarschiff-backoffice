# frozen_string_literal: true

module Citysdk
  class RequestsController < CitysdkController
    include Index

    #  skip_before_action :validate_service_request_id, only: :index
    before_action :encode_params, only: %i[create update]

    # Einzelner Vorgang nach ID
    # params:
    #   service_request_id  pflicht  - Vorgang-ID
    #   api_key             optional - API-Key
    #   extensions          optional - Response mit erweitereten Attributsausgaben
    def show
      @request = Citysdk::Request.where(id: params[:id])
      citysdk_response @request, root: :service_requests, element_name: :request,
                                 extensions: params[:extensions].try(:to_boolean),
                                 property_details: authorized?(:request_property_details),
                                 job_details: authorized?(:request_job_details)
    end

    # Neuen Vorgang anlegen
    # params:
    #   api_key                   pflicht - API-Key
    #   service_code              pflicht - Kategorie
    #   email                     pflicht - Autor-Email
    #   description               pflicht - Beschreibung
    #   lat                       optional - Latitude & Longitude ODER Address-String
    #   long                      optional - Latitude & Longitude ODER Address-String
    #   address_string            optional - Latitude & Longitude ODER Address-String
    #   photo_required            optional - Fotowunsch
    #   media                     optional - Foto (Base64-Encoded-String)
    #   privacy_policy_accepted   optional - Bestaetigung Datenschutz
    def create
      request = Request.new
      request.assign_attributes params.permit(:email, :service_code, :description, :lat, :long,
        :address_string, :photo_required, :media, :privacy_policy_accepted).merge(status: :pending)

      issue = request.becomes(Issue)
      issue.new_photo = request.new_photo if request.new_photo.present?
      issue.save!

      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true, status: :created
    end

    # Vorgang aktualisieren
    # params:
    #   api_key             pflicht  - API-Key
    #   service_request_id  pflicht  - Vorgang-ID
    #   email               pflicht  - Autor-Email
    #   service_code        optional - Kategorie
    #   description         optional - Beschreibung
    #   lat                 optional - Latitude & Longitude ODER Address-String
    #   long                optional - Latitude & Longitude ODER Address-String
    #   address_string      optional - Latitude & Longitude ODER Address-String
    #   photo_required      optional - Fotowunsch
    #   media               optional - Foto (Base64-Encoded-String)
    #   detailed_status     optional - Status (RECEIVED, IN_PROCESS, PROCESSED, REJECTED)
    #   status_notes        optional - Statuskommentar
    #   priority            optional - Prioritaet
    #   delegation          optional - Delegation
    #   job_status          optional - Auftrag-Status
    #   job_priority        optional - Auftrag-Prioritaet
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

    def confirm
      request = Request.find_by(status: :pending, confirmation_hash: params[:confirmation_hash])
      raise ActiveRecord::RecordNotFound if request.blank?
      issue = request.becomes(Issue)
      issue.status_received!
      citysdk_response request, root: :service_requests, element_name: :request, show_only_id: true
    end

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

    def encode_params
      params.each do |k, v|
        if k.in?(%w[email description address_string status_notes delegation]) && !v.is_utf8?
          params[k] = v.force_encoding('ISO-8859-1').encode('UTF-8')
        end
      end
    end
  end
end
