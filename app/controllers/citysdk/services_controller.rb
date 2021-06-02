# frozen_string_literal: true

module Citysdk
  class ServicesController < CitysdkController
    def index
      citysdk_response(Service.all,
        { root: :services, element_name: :service, document_url: authorized?(:citysdk_d3_document_url) })
    end

    def show
      service_definition = Citysdk::ServiceDefinition.where(id: params[:id])
      citysdk_response(service_definition, root: :service_definition, element_name: :service,
                                           document_url: authorized?(:citysdk_d3_document_url))
    end
  end
end
