# frozen_string_literal: true

require 'open-uri'

class Geocodr
  class << self
    def config
      @config ||= Settings::Geocodr
    end

    def address(issue)
      feature = get_features(issue, config.address_result_class).first
      return format_address(feature) if feature

      I18n.t 'geocodr.no_match'
    end

    def address_dms(issue)
      feature = get_features(issue, config.address_result_class).first
      return format_address_dms(feature) if feature

      I18n.t 'geocodr.no_match'
    end

    def parcel(issue)
      feature = get_features(issue, config.parcel_result_class).first
      return format_parcel(feature) if feature

      I18n.t 'geocodr.no_match'
    end

    def property_owner(issue)
      feature = get_features(issue, config.parcel_result_class).first
      return feature['x_katasterobjekt_id'][0] if feature

      I18n.t 'geocodr.no_match'
    end

    def search_places(pattern)
      query = pattern.to_s.strip
      return [] if query.empty?

      request_features(query, 'geocoding', config.places_result_class, 'EPSG:3857')
        .map { |p| Place.new(p).as_json }
    end

    def find(address)
      request_features(address, 'geocoding', config.places_result_class, 'EPSG:3857')
    end

    private

    def format_address(feature)
      primary_type = feature['primaryType']
      place_description = feature['placeDescription']
      localisator = config.localisator

      return place_description unless localisator.present?

      title = place_description.sub(/ \(.*$/, '')
      if ['Adresse', 'Straße'].include?(primary_type)
        title += " (#{place_description.sub(/^.* OT /, '')}"
      else
        title = place_description.sub(/^.* Bereich /, '')
      end
      title
    end

    def format_address_dms(feature)
      address_label = feature['x_strassenname'][0]
      address_label << " #{feature['x_hausnummer'][0]}" if feature['x_hausnummer'][0].present?
      address_label << " (#{feature['x_bereich'][0]})" if feature['x_bereich'][0].present?
      address_label
    end

    def format_parcel(feature)
      parcel_label = feature['x_katasterobjekt_id'][0].delete('_')
      "#{parcel_label[0, 6]}-#{parcel_label[6, 3]}-#{parcel_label[9, 5]}" +
        ("/#{parcel_label[14, 4]}" if parcel_label.length > 15).to_s
    end

    def get_features(issue, result_class)
      return [] if (features = request_features(issue, 'reverse', result_class, 'EPSG:4326')).blank?

      features.pluck('properties').sort_by { |a| a['entfernung'] }
    end

    def request_features(issue, mode, type, crs)
      uri = URI.parse(config.url)
      query = issue
      query = [issue.position.x, issue.position.y].join(',') if issue.respond_to?(:position) && issue.position.present?
      uri.query = URI.encode_www_form(request_feature_params(mode, type, query, crs))
      request_and_parse_features uri
    end

    def request_feature_params(mode, type, query, crs)
      query_params = mode == 'reverse' ? reverse_params(type, query, crs) : forward_params(type, query, crs)

      filter = config.localisator
      if filter.present?
        filter = filter.delete_prefix('[')
        key, value = filter.split(']=', 2)
        query_params["x_filter[#{key}]"] = value
      end

      query_params
    end

    def reverse_params(type, query, crs)
      {
        type: type,
        coord: query,
        crs: crs,
        rm: '100',
        sort: 'dist',
        n: '1'
      }
    end

    def forward_params(type, query, crs)
      {
        type: type,
        q: query,
        crs: crs,
        n: '5'
      }
    end

    def request_and_parse_features(uri)
      if (res = uri.open(request_uri_options)) && res.status.include?('OK')
        JSON.parse(res.read).try(:[], 'features')
      end
    rescue OpenURI::HTTPError
      Rails.logger.error "Geocodr Error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
      Rails.logger.error $ERROR_INFO.backtrace.join("\n  ")
      nil
    end

    def request_uri_options
      uri_options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
      uri_options[:proxy] = URI.parse(config.proxy) if config.respond_to?(:proxy) && config.proxy.present?
      uri_options
    end
  end
end
