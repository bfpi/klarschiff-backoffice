# frozen_string_literal: true

class FixSridOnAreas < ActiveRecord::Migration[6.0]
  def up
    %i[authority community county district instance observation].each do |table|
      change_column table, :area, :geometry, limit: { srid: 4326, type: :multi_polygon }
    end
    change_column :issue, :position, :geometry, limit: { srid: 0, type: :st_point }
  end

  def down; end
end
