# frozen_string_literal: true

module Citysdk
  class CoverageController < CitysdkController
    def valid
      citysdk_response(response_data)
    end

    def response_data
      if instances.blank? || (instance_url = instances.filter_map do |fm|
                                fm.instance_url.presence
                              end).present?
        rd = { result: false }
        rd[:instance_url] = instance_url.blank? ? Settings::Instance.parent_instance_url : instance_url.first
        return rd
      end
      { result: true }
    end

    def instances
      @instances ||= Instance.where('ST_Within(ST_SetSRID(ST_MakePoint(:long, :lat), 4326), area)',
        { lat: params[:lat].to_f, long: params[:long].to_f }).order(:instance_url)
    end
  end
end
