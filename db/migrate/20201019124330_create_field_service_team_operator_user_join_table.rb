# frozen_string_literal: true

class CreateFieldServiceTeamOperatorUserJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :field_service_team, :operator do |t|
      t.index %i[field_service_team_id operator_id], unique: true,
                                                     name: 'index_field_service_team_operator_on_team_and_operator'
      # t.index [:field_service_team_id, :operator]
    end
  end
end
