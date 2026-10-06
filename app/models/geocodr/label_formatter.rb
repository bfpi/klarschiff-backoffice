# frozen_string_literal: true

class Geocodr
  module LabelFormatter
    def self.format_address(primary_type, place_description)
      title = place_description.sub(/ \(.*$/, '')

      if %w[Adresse Straße].include?(primary_type)
        title += " (#{place_description.sub(/^.* OT /, '')}"
      else
        title = place_description.sub(/^.* Bereich /, '')
      end

      title
    end

    def self.format_address_dms(feature)
      address_label = feature['x_strassenname']&.first.to_s
      house_number = feature['x_hausnummer']&.first.to_s
      area = feature['x_bereich']&.first.to_s

      address_label << " #{house_number}" if house_number.present?
      address_label << " (#{area})" if area.present?

      address_label
    end

    def self.format_parcel(feature)
      parcel_label = feature['x_katasterobjekt_id']&.first.to_s.delete('_')
      return '' if parcel_label.empty?

      "#{parcel_label[0, 6]}-#{parcel_label[6, 3]}-#{parcel_label[9, 5]}" +
        ("/#{parcel_label[14, 4]}" if parcel_label.length > 15).to_s
    end
  end
end
