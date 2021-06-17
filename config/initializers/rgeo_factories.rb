# frozen_string_literal: true

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |store|
  store.default = RGeo::Cartesian.preferred_factory(srid: 4326, uses_lenient_assertions: true)
end
