# frozen_string_literal: true

module RegionalScope
  extend ActiveSupport::Concern

  class_methods do
    def regional(lat:, lon:)
      where('(ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) && "area")', lat: lat.to_f, lon: lon.to_f)
    end
  end
end
