# frozen_string_literal: true

module Citysdk
  class ServicesController < CitysdkController
    def index
      citysdk_response(sorted,
        { root: :services, element_name: :service, document_url: authorized?(:citysdk_d3_document_url) })
    end

    def show
      service_definition = Citysdk::ServiceDefinition.where(id: params[:id])
      citysdk_response(service_definition, root: :service_definition, element_name: :service,
                                           document_url: authorized?(:citysdk_d3_document_url))
    end

    private

    def sorted
      Service.all.joins(:main_category, :sub_category).includes(:main_category, :sub_category)
        .order('main_category.name': :asc, 'sub_category.name': :asc)
    end
  end
end
