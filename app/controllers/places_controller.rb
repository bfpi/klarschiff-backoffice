# frozen_string_literal: true

class PlacesController < ApplicationController
  require 'open-uri'

  def index
    return [] if (pattern = params[:pattern]).blank?
    uri = URI(Settings::Geocodr.url)
    query = if Settings::Geocodr.localisator.present?
              "#{Settings::Geocodr.localisator} #{pattern}"
            else
              pattern
            end
    uri.query = URI.encode_www_form(key: Settings::Geocodr.api_key, query: query,
                                    type: 'search', class: 'address', shape: 'bbox', limit: '5')

    render json: request_and_parse_features(uri).to_json
  end

  def request_and_parse_features(uri)
    places = []
    if (res = URI.open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)) && res.status.include?('OK')
      Array.wrap(JSON.parse(res.read).try(:[], 'features')).map do |p|
        places << Place.new(p)
      end
    end
    places
  end
end
