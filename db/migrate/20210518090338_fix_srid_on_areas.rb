# frozen_string_literal: true

class FixSridOnAreas < ActiveRecord::Migration[6.0]
  def up
    %i[authority community county district instance observation].each do |table|
      change_column table, :area, :geometry, limit: { srid: 4326, type: :multi_polygon }
    end
    Issue.update_all 'position = ST_GeomFromText(ST_AsText(position), 4326)' # rubocop:disable Rails/SkipsModelValidations
    change_column :issue, :position, :geometry, limit: { srid: 4326, type: :st_point }
  end

  def down; end
end
