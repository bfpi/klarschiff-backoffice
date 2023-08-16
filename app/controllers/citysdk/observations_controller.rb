# frozen_string_literal: true

module Citysdk
  class ObservationsController < CitysdkController
    # :apidoc: ### Create new observation
    # :apidoc: ```
    # :apidoc: POST http://[API endpoint]/observations.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | geometry | * | String | WKT geoemetry for observing area |
    # :apidoc: | area_code | * | String | IDs of districts, -1 for instance |
    # :apidoc: | problems | - | Boolean | Include problems |
    # :apidoc: | problem_service | - | String | Filter problems by main category IDs |
    # :apidoc: | problem_service_sub | - | String | Filter problems by sub category IDs |
    # :apidoc: | ideas | - | Boolean | Include problems |
    # :apidoc: | idea_service | | String | Filter ideas by main category IDs |
    # :apidoc: | idea_service_sub | | String | Filter ideas by sub category IDs |
    # :apidoc:
    # :apidoc: *: Either `geometry` or `area_code` is required
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <observation>
    # :apidoc:   <rss-id>39a855f0a4924af3217a217c8dc78ece</rss-id>
    # :apidoc: </observatio>
    # :apidoc: ```
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
