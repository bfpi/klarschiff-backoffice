# frozen_string_literal: true

module ArelTable
  extend ActiveSupport::Concern

  private

  ActiveRecord::Base.connection.tables.each do |table|
    define_method "#{table}_at" do
      table.camelize.constantize.arel_table
    end
  end
end
