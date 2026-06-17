# frozen_string_literal: true

module Citysdk
  class ServicesController < CitysdkController
    # :apidoc: ### GET services list
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/services.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: Parameters:
    # :apidoc:
    # :apidoc: | Name | Required | Type | Notes |
    # :apidoc: |:--|:-:|:--|:--|
    # :apidoc: | api_key | - | String | API key |
    # :apidoc: | group | - | String |  |
    # :apidoc: | keywords | - | String |  |
    # :apidoc: | lat | - | String |  |
    # :apidoc: | long | - | String |  |
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
    # :apidoc:     <keywords>category.parent.typ [problem|idea|tip]</keywords>
    # :apidoc:     <group>category.parent.name</group>
    # :apidoc:   </service>
    # :apidoc: </services>
    # :apidoc: ```
    def index
      citysdk_response(sorted,
        { root: :services, element_name: :service, document_url: authorized?(:citysdk_d3_document_url) })
    end

    # :apidoc: ### Get service definition
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/services/[id].[format]
    # :apidoc: ```
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
    # :apidoc:     <keywords>category.parent.typ [problem|idea|tip]</keywords>
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
      Service.active.eager_load(:main_category, :sub_category).where(id: regional_services.flatten.uniq)
        .order(main_category_arel_table[:name], sub_category_arel_table[:name])
    end

    def regional_services
      if (ag = authority_groups).present?
        Responsibility.active.where(group: ag.map(&:id),
          category: filtered_main_categories.map(&:categories)).map(&:category_id)
      else
        filtered_main_categories.map(&:category_ids)
      end
    end

    def authority_groups
      if (lat = params[:lat].to_f).positive? && (lon = params[:long].to_f).positive?
        ag = AuthorityGroup.active.regional(lat:, lon:)
        return ag if ag.none?(&:reference_default)
      end
      nil
    end

    def filtered_main_categories
      main_category = MainCategory.all
      main_category = main_category.where(name: params[:group]) if params[:group].present?
      main_category = main_category.where(kind: params[:keywords]) if params[:keywords].present?
      main_category
    end
  end
end
