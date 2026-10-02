# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :id, :bbox, :properties, :geometry

  def label
    primary_type = properties['primaryType']
    place_description = properties['placeDescription']

    return place_description unless Settings::Geocodr.localisator.present?

    format_label(primary_type, place_description)
  end

  def format_label(primary_type, place_description)
    title = place_description.sub(/ \(.*$/, '')

    if %w[Adresse Straße].include?(primary_type)
      title += " (#{place_description.sub(/^.* OT /, '')}"
    else
      title = place_description.sub(/^.* Bereich /, '')
    end

    title
  end

  def as_json(_options = {})
    {
      label: label,
      bbox: bbox
    }
  end
end
