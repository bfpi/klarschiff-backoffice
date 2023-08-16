# frozen_string_literal: true

module Citysdk
  class DiscoveryController < CitysdkController
    # :apidoc: ### Get discovery
    # :apidoc: ```
    # :apidoc: GET http://[API endpoint]/discovery.[format]
    # :apidoc: ```
    # :apidoc:
    # :apidoc: output values come from the config/citysdk.yml
    # :apidoc:
    # :apidoc: Sample Response:
    # :apidoc:
    # :apidoc: ```xml
    # :apidoc: <dicovery>
    # :apidoc:   <changeset>2015-11-05 08:43</changeset>
    # :apidoc:   <contact>
    # :apidoc:     "Hanse- und Universitätsstadt Rostock, Kataster-, Vermessungs- und Liegenschaftsamt,
    # :apidoc:     Holbeinplatz 14, 18069 Rostock, klarschiff.hro@rostock.de"
    # :apidoc:   </contact>
    # :apidoc:   <key_service>klarschiff.hro@rostock.de</key_service>
    # :apidoc:   <endpoints>
    # :apidoc:     <endpoint>
    # :apidoc:       <specification>http://wiki.open311.org/GeoReport_v2</specification>
    # :apidoc:       <url>https://geo.sv.rostock.de/citysdk</url>
    # :apidoc:       <changeset>2015-11-05 08:43</changeset>
    # :apidoc:       <type>production</type>
    # :apidoc:       <formats>
    # :apidoc:         <format>application/json</format>
    # :apidoc:         <format>text/xml</format>
    # :apidoc:       </formats>
    # :apidoc:     </endpoint>
    # :apidoc:     <endpoint>
    # :apidoc:       <specification>http://wiki.open311.org/GeoReport_v2</specification>
    # :apidoc:       <url>https://support.klarschiff-hro.de/citysdk</url>
    # :apidoc:       <changeset>2015-11-05 08:43</changeset>
    # :apidoc:       <type>test</type>
    # :apidoc:       <formats>
    # :apidoc:         <format>application/json</format>
    # :apidoc:         <format>text/xml</format>
    # :apidoc:       </formats>
    # :apidoc:     </endpoint>
    # :apidoc:     <endpoint>
    # :apidoc:       <specification>http://wiki.open311.org/GeoReport_v2</specification>
    # :apidoc:       <url>https://demo.klarschiff-hro.de/citysdk</url>
    # :apidoc:       <changeset>2015-11-05 08:43</changeset>
    # :apidoc:       <type>test</type>
    # :apidoc:       <formats>
    # :apidoc:         <format>application/json</format>
    # :apidoc:         <format>text/xml</format>
    # :apidoc:       </formats>
    # :apidoc:     </endpoint>
    # :apidoc:   </endpoints>
    # :apidoc: </discovery>
    # :apidoc: ```
    def index
      citysdk_response(Citysdk::Discovery.new, { element_name: :discovery })
    end
  end
end
