# frozen_string_literal: true

class AddAuthCodeToComment < ActiveRecord::Migration[6.0]
  def change
    add_reference :comment, :auth_code, foreign_key: true
  end
end
