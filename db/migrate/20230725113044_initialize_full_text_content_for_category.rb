# frozen_string_literal: true

class InitializeFullTextContentForCategory < ActiveRecord::Migration[7.0]
  def up
    Category.find_each { |o| o.send :update_full_text }
  end

  def down; end
end
