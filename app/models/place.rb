# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :id, :bbox, :properties, :geometry

  def label
    place_description = properties['placeDescription']
    return place_description if Settings::AddressSearch.localisator.blank?

    title = place_description.sub(/ \(.*$/, '')

    if %w[Adresse Straße].include?(properties['primaryType'])
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
