# frozen_string_literal: true

module Citysdk
  class AreasController < CitysdkController
    # Liste von Gebietsgrenzen
    # params:
    #   api_key         optional - API-Key
    #   area_code       optional - IDs der selektierten Stadtteile
    #   with_districts  optional - Response mit allen verfuegbaren Stadtteilgrenzen
    def index
      @response = [Instance.first]
      @response = District.all if params[:with_districts].present? && params[:area_code].blank?
      @response = District.find(params[:area_code].split(',')) if params[:area_code].present?
      citysdk_response(@response, { root: :areas, element_name: :area })
    end
  end
end
