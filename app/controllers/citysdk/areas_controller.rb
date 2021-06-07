# frozen_string_literal: true

module Citysdk
  class AreasController < CitysdkController
    # Liste von Gebietsgrenzen
    # params:
    #   api_key         optional - API-Key
    #   area_code       optional - IDs der selektierten Stadtteile
    #   with_districts  optional - Response mit allen verfuegbaren Stadtteilgrenzen
    def index
      @response = search_areas
      citysdk_response(@response, { root: :areas, element_name: :area })
    end

    private

    def search_areas
      search_class = Settings.main_instance? ? Citysdk::Authority : Citysdk::District
      response = [Instance.first]
      response = search_class.all if params[:with_districts].present? && params[:area_code].blank?
      response = search_class.find(params[:area_code].split(',')) if params[:area_code].present?
      response
    end
  end
end
