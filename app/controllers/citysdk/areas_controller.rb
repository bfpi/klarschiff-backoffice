# frozen_string_literal: true

module Citysdk
  class AreasController < CitysdkController
    # Liste von Gebietsgrenzen
    # params:
    #   api_key         optional - API-Key
    #   area_code       optional - IDs der selektierten Stadtteile
    #   with_districts  optional - Response mit allen verfuegbaren Stadtteilgrenzen
    def index
      @response = limit_response(order_response(search_areas))
      citysdk_response(@response,
        { root: :areas, element_name: :area })
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
        ActiveRecord::Base.sanitize_sql_for_order(['ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326), area)',
                                                   params[:center].first.to_f, params[:center].last.to_f])
      )
    end

    def limit_response(response)
      return response if params[:limit].blank?
      response.limit(params[:limit].to_i)
    end
  end
end
