# frozen_string_literal: true

module Citysdk
  class RequestsController < CitysdkController
    module Index
      extend ActiveSupport::Concern

      # Liste von Vorgaengen
      # params:
      #   api_key             optional - API-Key
      #   service_request_id  optional - Filter: Vorgangs-IDs(Kommaliste)
      #   service_code        optional - Filter: Kategorie-ID
      #   status              optional - Filter: Vorgangsstatus (Options: default=open, closed)
      #   detailed_status     optional - Filter: Vorgangsstatus (Options: PENDING, RECEIVED, IN_PROCESS, PROCESSED,
      #                                                                   REJECTED)
      #   start_date          optional - Filter: Meldungsdatum >= date
      #   end_date            optional - Filter: Meldungsdatum <= date
      #   updated_after       optional - Filter vorgang.version >= date
      #   updated_before      optional - Filter vorgang.version <= date
      #   agency_responsible  optional - Filter vorgang.auftrag.team
      #   extensions          optional - Response mit erweitereten Attributsausgaben
      #   lat                 optional - Schraenkt den Bereich ein, in dem gesucht wird (benoetigt: lat, long & radius)
      #   long                optional - Schraenkt den Bereich ein, in dem gesucht wird (benoetigt: lat, long & radius)
      #   radius              optional - Schraenkt den Bereich ein, in dem gesucht wird (benoetigt: lat, long & radius)
      #   keyword             optional - Filter: Meldungstyp (Problem|Idee|Tipp)
      #   max_requests        optional - Anzahl der neuesten Meldungen
      #   also_archived       optional - Filter: Auch Archivierte Meldungen beruecksichtigen
      #   just_count          optional - es soll nur die Anzahl der Meldungen zurueckgegeben werden
      #   observation_key     optional - MD5-Hash der zugehoerigen Beobachtungsflaeche
      #   with_picture        optional - Filter: Meldungen mit freigegebenen Fotos
      def index
        return index_just_counts if params[:just_count].present?

        citysdk_response filtered_requests, root: :service_requests, element_name: :request,
                                            extensions: params[:extensions].try(:to_boolean),
                                            property_details: authorized?(:request_property_details),
                                            job_details: authorized?(:request_job_details)
      end

      private

      def index_just_counts
        citysdk_response [{ count: filtered_requests.ids.count }], root: :service_requests
      end

      def filtered_requests
        Citysdk::RequestFilter.new(params, tips: authorized?(:read_tips)).collection
      end
    end
  end
end
