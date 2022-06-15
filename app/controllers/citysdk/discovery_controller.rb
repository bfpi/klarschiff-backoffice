# frozen_string_literal: true

module Citysdk
  class DiscoveryController < CitysdkController
    # :apidoc: ### Get discovery
    # :apidoc: <code>GET http://[API endpoint]/discovery.[format]</code>
    def index
      citysdk_response(Citysdk::Discovery.new, { element_name: :discovery })
    end
  end
end
