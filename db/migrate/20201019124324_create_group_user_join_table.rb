# frozen_string_literal: true

class CreateGroupUserJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :user, :group do |t|
      t.index %i[user_id group_id], unique: true
      # t.index [:group_id, :user_id]
    end
  end
end
