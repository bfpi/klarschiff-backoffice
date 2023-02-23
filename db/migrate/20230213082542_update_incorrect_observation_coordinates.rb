# frozen_string_literal: true

class UpdateIncorrectObservationCoordinates < ActiveRecord::Migration[6.0]
  def up
    Observation.find_each do |obs|
      next if obs.area.geometry_n(0).coordinates.flatten.first.to_i < 100
      sql = "UPDATE observation SET area = ST_Transform(ST_SetSRID(area, 25833), 4326) WHERE id = #{obs.id}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down; end
end
