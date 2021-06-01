# frozen_string_literal: true

module Citysdk
  class DiscoveryController < CitysdkController
    def index
      citysdk_response(Citysdk::Discovery.new, { element_name: :discovery })
    end
  end
end
