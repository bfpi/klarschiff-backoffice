# frozen_string_literal: true

require 'open-uri'

class PropertyOwnership
  class << self
    def config
      @config ||= Settings::PropertyOwnership
    end

    def format_property_owner(feature)
      return '' if config.attribute.blank?

      feature[config.attribute]&.to_s
    end

    def get_features(issue)
      return [] if (features = request_features(issue)).blank?

      features.pluck('properties')
    end

    def request_features(issue)
      uri = URI.parse(config.url)
      bbox = [issue.position.x, issue.position.y, issue.position.x, issue.position.y].join(',')
      query_params = {
        bbox: bbox,
        f: 'json'
      }
      uri.query = URI.encode_www_form(query_params)
      request_and_parse_features uri
    end

    def request_and_parse_features(uri)
      if (res = uri.open(request_uri_options)) && res.status.include?('OK')
        JSON.parse(res.read).try(:[], 'features')
      end
    rescue OpenURI::HTTPError, Net::OpenTimeout, Net::ReadTimeout
      Rails.logger.error "PropertyOwnership Error: #{$ERROR_INFO.inspect}, #{$ERROR_INFO.message}\n"
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
