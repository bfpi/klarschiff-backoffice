# frozen_string_literal: true

class Place
  include ActiveModel::Model

  attr_accessor :type, :properties, :geometry

  def as_json(_options = {})
    {
      label: format_label(properties),
      bbox: format_bbox(geometry),
      transform_bbox: geometry['transform_bbox'],
      feature_id: properties['feature_id']
    }
  end

  private

  def format_label(properties)
    if properties['objektgruppe'] == 'Gemeindeteil' || properties['abkuerzung'].blank?
      properties['_title_'].split(', ')[-1]
    else
      "#{properties['_title_'].split(', ')[-1]} (#{properties['abkuerzung']})"
    end
  end

  def format_bbox(geometry)
    return format_bbox_point(geometry) if geometry['type'] == 'Point'
    format_bbox_prectangl(geometry)
  end

  def format_bbox_point(geometry)
    [geometry['coordinates'][0], geometry['coordinates'][1], geometry['coordinates'][0], geometry['coordinates'][1]]
  end

  def format_bbox_prectangl(geometry)
    [
      geometry['coordinates'][0][0][0], geometry['coordinates'][0][0][1],
      geometry['coordinates'][0][2][0], geometry['coordinates'][0][2][1]
    ]
  end
end
