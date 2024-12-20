# frozen_string_literal: true

module Citysdk
  class Observation < ::Observation
    include Citysdk::Serialization

    self.serialization_attributes = [:rss_id]

    def rss_id
      key
    end

    def area_code=(value)
      self.area = Instance.current.first.area and return if value.to_i == -1
      self.area = cast_areas_to_cartesian_multipolygon(Settings.area_level.where(id: ids_from(value)).pluck(:area))
    end

    def geometry=(value)
      self.area = value if value.present?
    end

    def ideas=(_value); end

    def problems=(_value); end

    def idea_service=(value)
      self.category_ids = (categories + main_categories.kind_idea.where(id: ids_from(value))
        .map(&:categories)).flatten.map(&:id).join(',')
    end

    def problem_service=(value)
      self.category_ids = (categories + main_categories.kind_problem.where(id: ids_from(value))
        .map(&:categories)).flatten.map(&:id).join(',')
    end

    def idea_service_sub=(value)
      self.category_ids = main_categories.kind_idea.map(&:categories).flatten.map(&:sub_categories).flatten
        .select { |sc| sc.id.in? ids_from(value) }.map(&:categories).flatten.map(&:id).join(',')
    end

    def problem_service_sub=(value)
      self.category_ids = main_categories.kind_problem.map(&:categories).flatten.map(&:sub_categories).flatten
        .select { |sc| sc.id.in? ids_from(value) }.map(&:categories).flatten.map(&:id).join(',')
    end

    private

    def main_categories
      MainCategory.active
    end

    def cast_areas_to_cartesian_multipolygon(areas)
      factory = RGeo::Cartesian.preferred_factory(srid: 4326)
      factory.multi_polygon(areas.map { |d| factory.parse_wkt(d.as_text) })
    end

    def ids_from(value)
      value.split(',').map(&:to_i)
    end
  end
end
