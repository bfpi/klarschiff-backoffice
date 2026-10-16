# frozen_string_literal: true

require 'open-uri'

module FeatureRequest
  extend ActiveSupport::Concern

  class_methods do
    private

    def features(params)
      res = uri(params).open(open_options)
      return [] unless res.status.include?('OK')

      JSON.parse(res.read).fetch('features', [])
    rescue OpenURI::HTTPError, Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "#{name} Error: #{e.inspect}\n  #{e.backtrace.join("\n  ")}"
      []
    end

    def uri(params)
      URI.parse(config.url).tap { |uri| uri.query = URI.encode_www_form(params) }
    end

    def open_options
      options = { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }
      options[:proxy] = URI.parse(config.proxy) if config.respond_to?(:proxy) && config.proxy.present?
      options
    end
  end
end
