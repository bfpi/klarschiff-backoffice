# frozen_string_literal: true

module Citysdk
  class AreasController < CitysdkController
    # :apidoc: ### Get observable areas
    # :apidoc: <code>GET http://[API endpoint]/areas.[format]</code>
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | X | String | API key |
    # :apidoc: | area_code | - | Integer[] | IDs to filter districts |
    # :apidoc: | with_districts | - | Boolean | return all existing districts, not available if using area_code |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <areas>
    # :apidoc:   <area>
    # :apidoc:     <id>30</id>
    # :apidoc:     <name>Biestow</name>
    # :apidoc:     <grenze>MULTIPOLYGON (((...)))</grenze>
    # :apidoc:   </area>
    # :apidoc:   ...
    # :apidoc: </areas>
    # :apidoc: ```
    def index
      citysdk_response limit_response(order_response(search_areas)), { root: :areas, element_name: :area }
    end

    private

    def search_areas
      search_class = Settings.main_instance? ? Citysdk::Authority : Citysdk::District
      response = Instance.first
      response = search_class.all if params[:with_districts].present? && params[:area_code].blank?
      response = search_class.where(id: params[:area_code].split(',')) if params[:area_code].present?
      response
    end

    def order_response(response)
      return response if params[:center].blank?
      response.order(
        ActiveRecord::Base.sanitize_sql_for_order(
          [Arel.sql('ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326), area)'),
           params[:center].first.to_f, params[:center].last.to_f]
        )
      )
    end

    def limit_response(response)
      return response if params[:limit].blank?
      response.limit(params[:limit].to_i)
    end
  end
end
