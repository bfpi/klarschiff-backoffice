# frozen_string_literal: true

module Citysdk
  class ServicesController < CitysdkController
    # :apidoc: ### GET services list
    # :apidoc: <code>GET http://[API endpoint]/services.[format]</code>
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | - | String | API key |
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <services type="array">
    # :apidoc:   <service>
    # :apidoc:     <service_code>category.id</service_code>
    # :apidoc:     <service_name>category.name</service_name>
    # :apidoc:     <description/>
    # :apidoc:     <metadata>false</metadata>
    # :apidoc:     <type>realtime</type>
    # :apidoc:     <keywords>category.parent.typ [problem|idee|tipp]</keywords>
    # :apidoc:     <group>category.parent.name</group>
    # :apidoc:   </service>
    # :apidoc: </services>
    # :apidoc: ```
    def index
      citysdk_response(sorted,
        { root: :services, element_name: :service, document_url: authorized?(:citysdk_d3_document_url) })
    end

    # :apidoc: ### Get service definition
    # :apidoc: <code>GET http://[API endpoint]/services/[id].[format]</code>
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | - | String | API key |
    # :apidoc: | id | X | Integer | ID of service|
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <service_definition type="array">
    # :apidoc:   <service>
    # :apidoc:     <service_code>category.id</service_code>
    # :apidoc:     <service_name>category.name</service_name>
    # :apidoc:     <keywords>category.parent.typ [problem|idee|tipp]</keywords>
    # :apidoc:     <group>category.parent.name</group>
    # :apidoc:   </service>
    # :apidoc: </service_definition>
    # :apidoc: ```
    def show
      service_definition = Citysdk::ServiceDefinition.where(id: params[:id])
      citysdk_response(service_definition, root: :service_definition, element_name: :service,
        document_url: authorized?(:citysdk_d3_document_url))
    end

    private

    def sorted
      Service.eager_load(:main_category, :sub_category)
        .order(MainCategory.arel_table[:name], SubCategory.arel_table[:name])
    end
  end
end
