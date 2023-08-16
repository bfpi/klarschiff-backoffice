# frozen_string_literal: true

module Citysdk
  class CoverageController < CitysdkController
    # :apidoc: ### Get position coverage
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/coverage.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | lat | X | Float | latitude value |
    # :apidoc: | long | X | Float | longitude value |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <hash>
    # :apidoc:   <result type="boolean">false</result>
    # :apidoc: </hash>
    # :apidoc: ```
    def valid
      citysdk_response response_data
    end

    private

    def response_data
      if instances.blank? || (instance_url = instances.filter_map do |fm|
                                fm.instance_url.presence
                              end).present?
        rd = { result: false }
        rd[:instance_url] = instance_url.blank? ? Settings::Instance.parent_instance_url : instance_url.first
        return rd
      end
      { result: true }
    end

    def instances
      @instances ||= Instance.regional(lat: params[:lat], lon: params[:long]).order(:instance_url)
    end
  end
end
