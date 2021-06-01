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
      self.area = cast_districts_to_cartesian_multipolygon(District.where(id: ids_from(value)).pluck(:area))
    end

    def geometry=(value)
      self.area = value
    end

    def ideas=(_value); end

    def problems=(_value); end

    def idea_service=(value)
      self.category_ids = (categories + MainCategory.kind_idea.where(id: ids_from(value))
        .map(&:categories)).flatten.map(&:id).join(',')
    end

    def problem_service=(value)
      self.category_ids = (categories + MainCategory.kind_problem.where(id: ids_from(value))
        .map(&:categories)).flatten.map(&:id).join(',')
    end

    def idea_service_sub=(value)
      self.category_ids = MainCategory.kind_idea.map(&:categories).flatten.map(&:sub_categories).flatten
        .select { |sc| sc.id.in? ids_from(value) }.map(&:categories).flatten.map(&:id).join(',')
    end

    def problem_service_sub=(value)
      self.category_ids = MainCategory.kind_problem.map(&:categories).flatten.map(&:sub_categories).flatten
        .select { |sc| sc.id.in? ids_from(value) }.map(&:categories).flatten.map(&:id).join(',')
    end

    private

    def cast_districts_to_cartesian_multipolygon(districts)
      factory = RGeo::Cartesian.preferred_factory(srid: 4326)
      factory.multi_polygon(districts.map { |d| factory.parse_wkt(d.as_text) })
    end

    def ids_from(value)
      value.split(',').map(&:to_i)
    end
  end
end