# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :id, :bbox, :properties, :geometry

  def label
    Geocodr::LabelFormatter.format_address(properties)
  end

  def as_json(_options = {})
    {
      label: label,
      bbox: bbox
    }
  end
end
