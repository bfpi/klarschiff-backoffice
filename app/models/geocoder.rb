# frozen_string_literal: true

class Geocoder
  include FeatureRequest

  class << self
    def config
      @config ||= Settings::AddressSearch
    end

    def address(issue)
      feature = reverse(issue, config.address_result_class)
      return Place.new(properties: feature['properties']).label if feature

      I18n.t 'geocoder.no_match'
    end

    def address_dms(issue)
      feature = reverse(issue, config.address_result_class)
      LabelFormatter.format_address_dms(feature['properties']) if feature
    end

    def parcel(issue)
      feature = reverse(issue, config.parcel_result_class)
      return LabelFormatter.format_parcel(feature['properties']) if feature

      I18n.t 'geocoder.no_match'
    end

    def property_owner(issue)
      PropertyOwnership.owner(issue).presence || I18n.t('geocoder.no_match')
    end

    def search_places(pattern)
      return [] if pattern.blank?

      search(pattern.strip, crs: 'EPSG:3857').map { |p| Place.new(p).as_json }
    end

    def find(address)
      search(address, crs: 'EPSG:4326')
    end

    private

    def search(pattern, crs:)
      features(type: config.places_result_class, q: pattern, crs:, n: 5, **filter_params)
    end

    def reverse(issue, type)
      return if (position = issue.position).blank?

      features(type:, coord: "#{position.x},#{position.y}", crs: 'EPSG:4326', rm: 100, sort: 'dist', n: 1,
        **filter_params).first
    end

    def filter_params
      return {} if (filter = config.localisator).blank?

      key, value = filter.delete_prefix('[').split(']=', 2)
      { "x_filter[#{key}]" => value }
    end
  end
end
