# frozen_string_literal: true

module Citysdk
  class ObservationsController < CitysdkController
    # Neue Beobachtungsflaeche anlegen
    # params:
    #   area_code             optional - IDs der Stadtteilgrenze (-1 fuer Stadtgrenze)
    #   geometry              optional - Geometrie einer erstellten Flaeche als WKT
    #   problems              optional - Probleme ueberwachen
    #   problem_service       optional - IDs ausgewaehlter Hauptkategorien fuer Probleme
    #   problem_service_sub   optional - IDs ausgewaehlter Unterkategorien fuer Probleme
    #   ideas                 optional - Ideen ueberwachen
    #   idea_service          optional - IDs ausgwaehlte Hauptkategorien fuer Ideen
    #   idea_service_sub      optional - IDs ausgwaehlte Unterkategorien fuer Ideen
    def create
      observation = Citysdk::Observation.new
      observation.assign_attributes(params.permit(:area_code, :geometry, :problems, :problem_service,
        :problem_service_sub, :ideas, :idea_service, :idea_service_sub))

      obs = observation.becomes(::Observation)
      obs.save!

      citysdk_response observation, element_name: :observation, status: :created
    end
  end
end
