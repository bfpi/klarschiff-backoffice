# frozen_string_literal: true

require 'open-uri'

class Geocodr
  class << self
    def config
      @config ||= Settings::Geocodr
    end

    def address(issue)
      order_features(issue, config.address_search_class).select do |feature|
        next if feature['objektgruppe'] != config.address_object_group
        return format_address(feature)
      end
      I18n.t 'geocodr.no_match'
    end

    def parcel(issue)
      order_features(issue, config.parcel_search_class).map do |feature|
        next if feature['objektgruppe'] != config.parcel_object_group
        return feature['flurstueckskennzeichen']
      end
      I18n.t 'geocodr.no_match'
    end

    def property_owner(issue)
      order_features(issue, config.property_owner_search_class).map do |feature|
        next if feature['objektgruppe'] != config.property_owner_object_group
        return feature['eigentuemer']
      end
      I18n.t 'geocodr.no_match'
    end

    def search_places(pattern)
      places = []
      query = if Settings::Geocodr.respond_to?(:localisator)
                "#{Settings::Geocodr.localisator} #{pattern}"
              else
                pattern
              end
      request_features(query, config.places_search_class, type: :search, shape: :bbox).map do |place|
        places << Place.new(place)
      end
      places
    end

    private

    def format_address(feature)
      addr = feature['strasse_name']
      addr << " #{feature['hausnummer']}" if feature['hausnummer'].present?
      addr << feature['hausnummer_zusatz'] if feature['hausnummer_zusatz'].present?
      addr << " (#{feature['gemeindeteil_abkuerzung']})" if feature['gemeindeteil_abkuerzung'].present?
      addr
    end

    def order_features(issue, search_class)
      request_features(issue, search_class).map { |f| f['properties'] }.sort_by { |a| a['entfernung'] }
    end

    def request_features(issue, search_class, type: :reverse, shape: nil)
      uri = URI(config.url)
      query = issue
      query = [issue.position.x, issue.position.y].join(',') if issue.respond_to?(:position)
      uri.query = URI.encode_www_form(request_feature_params(query, type, search_class, shape))
      request_and_parse_features(uri)
    end

    def request_feature_params(query, type, search_class, shape)
      uri_params = {
        key: config.api_key,
        query: query,
        type: type,
        class: search_class,
        in_epsg: 4326,
        limit: 5
      }
      uri_params[:shape] = shape if shape.present?
      uri_params
    end

    def request_and_parse_features(uri)
      if (res = URI.open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)) && res.status.include?('OK')
        return JSON.parse(res.read).try(:[], 'features')
      end
      nil
    end
  end
end
