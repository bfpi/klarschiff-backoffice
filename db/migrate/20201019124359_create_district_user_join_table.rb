# frozen_string_literal: true

class CreateDistrictUserJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :user, :district do |t|
      t.index %i[user_id district_id], unique: true
      # t.index [:district_id, :user_id]
    end
  end
end
