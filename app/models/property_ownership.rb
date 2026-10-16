# frozen_string_literal: true

class PropertyOwnership
  include FeatureRequest

  class << self
    def config
      @config ||= Settings::PropertyOwnership
    end

    def owner(issue)
      return if config.url.blank? || config.attribute.blank? || issue.position.blank?

      features(bbox: bbox(issue.position), f: 'json').first&.dig('properties', config.attribute)&.to_s
    end

    private

    def bbox(position)
      [position.x, position.y, position.x, position.y].join(',')
    end
  end
end
