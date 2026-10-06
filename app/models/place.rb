# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :id, :bbox, :properties, :geometry

  def label
    primary_type = properties['primaryType']
    place_description = properties['placeDescription']

    return place_description if Settings::Geocodr.localisator.blank?

    Geocodr::LabelFormatter.format_address(primary_type, place_description)
  end

  def as_json(_options = {})
    {
      label: label,
      bbox: bbox
    }
  end
end
