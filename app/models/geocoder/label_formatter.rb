# frozen_string_literal: true

class Geocoder
  module LabelFormatter
    Address = Struct.new(:place_name, :street_name, :street_key, :housenumber, keyword_init: true)

    def self.format_address_dms(feature)
      Address.new(
        place_name: feature['x_bereich']&.first.to_s,
        street_name: feature['x_strassenname']&.first.to_s,
        street_key: feature['x_strassenschluessel']&.first.to_s[-5..],
        housenumber: feature['x_hausnummer']&.first.to_s
      )
    end

    def self.format_parcel(feature)
      parcel_label = feature['x_katasterobjekt_id']&.first.to_s.delete('_')
      return '' if parcel_label.empty?

      "#{parcel_label[0, 6]}-#{parcel_label[6, 3]}-#{parcel_label[9, 5]}" +
        ("/#{parcel_label[14, 4]}" if parcel_label.length > 15).to_s
    end
  end
end
