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
    # :apidoc: | area_code | - | Integer / String | ID to filter districts, separated by comma for multiple values |
    # :apidoc: | search_class | - | String | specifies which data to search for |
    # :apidoc: | regional_key | - | Integer / String | RegionalKey to filter region (based on search_class) |
    # :apidoc: | with_districts | - | Boolean | return all existing districts, not available if using area_code |
    # :apidoc:
    # :apidoc: Available SeachClasses for this action: `authority`, `district`
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
      if (response = search_areas_by_params).present?
        return response
      end
      return search_class.all if params[:with_districts].present? && params[:area_code].blank?
      Instance.first
    end

    def search_areas_by_params
      return search_areas_by_area_code if params[:area_code].present?
      return search_areas_by_regional_key if params[:regional_key].present?
    end

    def search_areas_by_area_code
      search_class.where(id: params[:area_code].split(','))
    end

    def search_areas_by_regional_key
      search_class.where(regional_key: params[:regional_key])
    end

    def search_class
      if params[:search_class]
        return case params[:search_class].to_sym
               when :authority
                 return Citysdk::Authority
               else
                 return Citysdk::District
               end
      end
      Settings.main_instance? ? Citysdk::Authority : Citysdk::District
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
