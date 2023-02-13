# frozen_string_literal: true

class UpdateIncorrectObservationCoordinates < ActiveRecord::Migration[6.0]
  def up
    Observation.all.each do |obs|
      next if obs.area.geometry_n(0).coordinates.flatten.first.to_i < 100
      sql = "UPDATE observation set area = ST_Transform(ST_SetSRID(area, 25833), 4326) where id = #{ obs.id }"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down
  end
end
